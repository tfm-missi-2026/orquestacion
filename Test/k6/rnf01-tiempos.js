import http from "k6/http";
import { check, group } from "k6";

const BASE = __ENV.BASE_URL || "http://localhost:8080";
const EMAIL = __ENV.ADMIN_EMAIL || "admin@srp.local";
const PASSWORD = __ENV.ADMIN_PASSWORD || "Admin123";

const SUBPROYECTOS = Number(__ENV.SUBPROYECTOS || 3);
const TAREAS = Number(__ENV.TAREAS || 20);
const BITACORAS = Number(__ENV.BITACORAS || 40);

export const options = {
  vus: Number(__ENV.VUS || 10),
  duration: __ENV.DURACION || "30s",
  thresholds: {
    "http_req_duration{operacion:consulta}": ["p(95)<1500"],
    "http_req_duration{operacion:escritura}": ["p(95)<3000"],
    "http_req_failed": ["rate<0.01"],
  },
};

function json(token) {
  return {
    headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
  };
}

function primerId(res) {
  const cuerpo = res.json();
  return Array.isArray(cuerpo) && cuerpo.length > 0 ? cuerpo[0].id : null;
}

function idPorOpcion(res, opcion) {
  const cuerpo = res.json();
  const fila = cuerpo.find((c) => c.opcion === opcion);
  return fila ? fila.id : null;
}

export function setup() {
  const login = http.post(
    `${BASE}/api/auth/login`,
    JSON.stringify({ email: EMAIL, contrasenia: PASSWORD }),
    { headers: { "Content-Type": "application/json" } },
  );
  if (login.status !== 200) {
    throw new Error(`login fallido: ${login.status} ${login.body}`);
  }
  const token = login.json("tokenAcceso");
  const adminId = login.json("usuario.id");
  const cfg = json(token);

  const tipoSub = primerId(http.get(`${BASE}/api/catalogo/grupo/TIPO_SUBPROYECTO`, cfg));
  const prioridad = primerId(http.get(`${BASE}/api/catalogo/grupo/PRIORIDAD`, cfg));
  const situacionRes = http.get(`${BASE}/api/catalogo/grupo/SITUACION`, cfg);
  const situacion = idPorOpcion(situacionRes, "Pendiente");
  const tipoVariacion = primerId(http.get(`${BASE}/api/catalogo/grupo/TIPO_VARIACION`, cfg));

  const usuarios = http.get(`${BASE}/api/usuarios/todos`, cfg).json().map((u) => u.id);
  if (!tipoSub || !prioridad || !situacion || !tipoVariacion || usuarios.length === 0) {
    throw new Error("no se pudieron resolver los catalogos o los usuarios");
  }

  const marca = `K6-${Date.now()}`;

  const proyecto = http.post(
    `${BASE}/api/proyectos`,
    JSON.stringify({
      nombreCorto: marca.slice(0, 20),
      nombre: `Proyecto de medicion ${marca}`,
      gestorId: adminId,
    }),
    cfg,
  );
  const proyectoId = proyecto.json("id");
  if (!proyectoId) {
    throw new Error(`no se pudo crear el proyecto: ${proyecto.status} ${proyecto.body}`);
  }

  const subproyectos = [];
  for (let i = 0; i < SUBPROYECTOS; i++) {
    const res = http.post(
      `${BASE}/api/subproyectos`,
      JSON.stringify({
        proyectoId,
        tipoSubproyectoId: tipoSub,
        codigoTicket: `${marca}-${i}`,
        prioridadId: prioridad,
        descripcion: `Subproyecto ${i} de la medicion de rendimiento`,
        solicitanteId: adminId,
        fechaSolicitud: "2026-09-01",
        situacionId: situacion,
      }),
      cfg,
    );
    if (res.json("id")) subproyectos.push(res.json("id"));
  }

  const tareas = [];
  for (let i = 0; i < TAREAS; i++) {
    const res = http.post(
      `${BASE}/api/tareas`,
      JSON.stringify({
        subproyectoId: subproyectos[i % subproyectos.length],
        nombre: `Tarea ${i} de la medicion de rendimiento`,
        fechaInicioPlanificada: "2026-09-01",
        fechaFinPlanificada: "2026-09-30",
        horasEstimadas: 20,
        situacionId: situacion,
      }),
      cfg,
    );
    if (res.json("id")) tareas.push(res.json("id"));
  }

  const asignaciones = [];
  for (let i = 0; i < tareas.length; i++) {
    const res = http.post(
      `${BASE}/api/asignaciones`,
      JSON.stringify({
        tareaId: tareas[i],
        usuarioId: usuarios[i % usuarios.length],
        horasPlanificadas: 8,
        fechaInicioPlanificada: "2026-09-01",
        fechaFinPlanificada: "2026-09-30",
        confirmarSobrecarga: true,
      }),
      cfg,
    );
    if (res.json("id")) asignaciones.push(res.json("id"));
  }

  const congelar = http.post(
    `${BASE}/api/linea-base/congelar`,
    JSON.stringify({
      proyectoId,
      descripcion: `Linea base de la medicion ${marca}`,
      tareas: tareas.map((id, i) => ({
        tareaId: id,
        nombre: `Tarea ${i} de la medicion de rendimiento`,
        fechaInicioPlanificada: "2026-09-01",
        fechaFinPlanificada: "2026-09-30",
        horasEstimadas: 20,
      })),
      asignaciones: asignaciones.map((id, i) => ({
        asignacionId: id,
        tareaId: tareas[i],
        usuarioId: usuarios[i % usuarios.length],
      })),
    }),
    cfg,
  );
  if (congelar.status !== 200 && congelar.status !== 201) {
    throw new Error(`no se pudo congelar la linea base: ${congelar.status} ${congelar.body}`);
  }

  let bitacoras = 0;
  for (let i = 0; i < BITACORAS && asignaciones.length > 0; i++) {
    const dia = String((i % 20) + 1).padStart(2, "0");
    const hora = String(7 + Math.floor(i / 20)).padStart(2, "0");
    const res = http.post(
      `${BASE}/api/bitacora`,
      JSON.stringify({
        fecha: `2026-09-${dia}`,
        horaInicio: `${hora}:00:00`,
        horaFin: `${hora}:30:00`,
        descripcion: `Registro ${i} de la medicion de rendimiento`,
        asignacionId: asignaciones[i % asignaciones.length],
      }),
      cfg,
    );
    if (res.status === 200 || res.status === 201) bitacoras++;
  }

  console.log(
    `volumen: 1 proyecto, ${subproyectos.length} subproyectos, ${tareas.length} tareas, ` +
      `${asignaciones.length} asignaciones, ${bitacoras} registros de bitacora`,
  );

  return {
    token,
    adminId,
    proyectoId,
    tipoVariacion,
    tareaId: tareas[0],
    volumen: {
      subproyectos: subproyectos.length,
      tareas: tareas.length,
      asignaciones: asignaciones.length,
      bitacoras,
    },
  };
}

export default function (data) {
  const auth = { Authorization: `Bearer ${data.token}` };
  const consulta = { headers: auth, tags: { operacion: "consulta" } };
  const escritura = {
    headers: { ...auth, "Content-Type": "application/json" },
    tags: { operacion: "escritura" },
  };

  group("consultas", () => {
    const rutas = [
      "/api/proyectos",
      "/api/subproyectos",
      "/api/tareas",
      "/api/asignaciones",
      "/api/variaciones",
      "/api/catalogo",
      `/api/avance/por-proyecto/${data.proyectoId}`,
      "/api/carga/equipo?desde=2026-09-01&hasta=2026-09-30",
    ];
    for (const ruta of rutas) {
      const res = http.get(`${BASE}${ruta}`, consulta);
      check(res, { [`200 ${ruta}`]: (r) => r.status === 200 });
    }
  });

  group("escrituras", () => {
    const cuerpo = JSON.stringify({
      tipoVariacionId: data.tipoVariacion,
      descripcion: `Medicion de rendimiento ${__VU}-${__ITER}`,
      justificacion: "Registro generado por la prueba de carga de RNF-01",
      valorAnterior: "2026-09-01",
      valorNuevo: "2026-09-08",
      fechaDeteccion: "2026-09-08",
      reportadaPor: data.adminId,
      tareaId: data.tareaId,
    });
    const res = http.post(`${BASE}/api/variaciones`, cuerpo, escritura);
    check(res, { "variacion creada": (r) => r.status === 200 || r.status === 201 });
  });
}

function ms(valor) {
  if (valor === undefined || valor === null) return "n/d";
  return valor >= 1000
    ? `${(valor / 1000).toFixed(2)} s`
    : `${valor.toFixed(2)} ms`;
}

function miles(valor) {
  return String(Math.round(valor || 0)).replace(/\B(?=(\d{3})+(?!\d))/g, ".");
}

function bytes(valor) {
  const gb = (valor || 0) / 1e9;
  return gb >= 1 ? `${gb.toFixed(1)} GB` : `${((valor || 0) / 1e6).toFixed(1)} MB`;
}

function filaTrend(titulo, metrica, umbral) {
  if (!metrica) return "";
  const v = metrica.values;
  const p95 = v["p(95)"];
  const cumple = umbral ? p95 < umbral : null;
  const estado =
    cumple === null
      ? ""
      : cumple
        ? '<span class="ok">Cumple</span>'
        : '<span class="falla">No cumple</span>';
  return `<tr>
    <td>${titulo}</td>
    <td class="num">${ms(v.avg)}</td>
    <td class="num">${ms(v.med)}</td>
    <td class="num destacado">${ms(p95)}</td>
    <td class="num">${ms(v.max)}</td>
    <td class="num">${umbral ? ms(umbral) : "—"}</td>
    <td>${estado}</td>
  </tr>`;
}

function filasChecks(grupo) {
  const filas = [];
  const recorrer = (g) => {
    (g.checks || []).forEach((c) => {
      const total = (c.passes || 0) + (c.fails || 0);
      const pct = total > 0 ? ((c.passes / total) * 100).toFixed(1) : "0.0";
      const clase = (c.fails || 0) === 0 ? "ok" : "falla";
      filas.push(`<tr>
        <td>${c.name}</td>
        <td class="num">${miles(c.passes)}</td>
        <td class="num">${miles(c.fails)}</td>
        <td class="num"><span class="${clase}">${pct} %</span></td>
      </tr>`);
    });
    (g.groups || []).forEach(recorrer);
  };
  if (grupo) recorrer(grupo);
  return filas.join("\n");
}

export function handleSummary(data) {
  const m = data.metrics || {};
  const consulta = m["http_req_duration{operacion:consulta}"];
  const escritura = m["http_req_duration{operacion:escritura}"];
  const peticiones = m.http_reqs ? m.http_reqs.values : {};
  const fallidas = m.http_req_failed ? m.http_req_failed.values : {};
  const iteraciones = m.iterations ? m.iterations.values : {};
  const recibidos = m.data_received ? m.data_received.values.count : 0;

  const vus = options.vus;
  const duracion = options.duration;
  const fecha = new Date().toLocaleString("es-PE");
  const titulo = __ENV.TITULO || "Medición de tiempos de respuesta";
  const salida = __ENV.INFORME || "informe.html";

  const html = `<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<title>SPSRT · ${titulo}</title>
<style>
  :root { color-scheme: light; }
  body { font-family: "Segoe UI", system-ui, sans-serif; margin: 0; padding: 2.5rem;
         background: #f6f7f9; color: #1f2430; }
  main { max-width: 60rem; margin: 0 auto; }
  h1 { font-size: 1.5rem; margin: 0 0 .25rem; }
  h2 { font-size: 1.05rem; margin: 2rem 0 .75rem; padding-bottom: .35rem;
       border-bottom: 1px solid #d8dce3; }
  .meta { color: #5b6472; font-size: .875rem; margin-bottom: 1.5rem; }
  table { width: 100%; border-collapse: collapse; background: #fff;
          border: 1px solid #d8dce3; border-radius: 6px; overflow: hidden; }
  th, td { padding: .55rem .75rem; text-align: left; font-size: .875rem;
           border-bottom: 1px solid #eceef2; }
  th { background: #eef1f5; font-weight: 600; }
  tr:last-child td { border-bottom: none; }
  .num { text-align: right; font-variant-numeric: tabular-nums; }
  .destacado { font-weight: 700; }
  .ok { color: #1a7f4b; font-weight: 600; }
  .falla { color: #b3261e; font-weight: 600; }
  .tarjetas { display: grid; grid-template-columns: repeat(auto-fit, minmax(11rem, 1fr));
              gap: .75rem; margin-top: .5rem; }
  .tarjeta { background: #fff; border: 1px solid #d8dce3; border-radius: 6px; padding: .85rem 1rem; }
  .tarjeta .valor { font-size: 1.35rem; font-weight: 700; }
  .tarjeta .rotulo { font-size: .75rem; color: #5b6472; text-transform: uppercase;
                     letter-spacing: .04em; }
  .nota { font-size: .8125rem; color: #5b6472; margin-top: .75rem; }
</style>
</head>
<body>
<main>
  <h1>SPSRT · ${titulo}</h1>
  <p class="meta">Ejecutado el ${fecha} · ${vus} usuarios virtuales durante ${duracion} ·
     stack completo en Docker, a través del API Gateway.</p>

  <h2>Resumen</h2>
  <div class="tarjetas">
    <div class="tarjeta"><div class="rotulo">Peticiones</div>
      <div class="valor">${miles(peticiones.count)}</div></div>
    <div class="tarjeta"><div class="rotulo">Peticiones por segundo</div>
      <div class="valor">${miles(peticiones.rate)}</div></div>
    <div class="tarjeta"><div class="rotulo">Iteraciones</div>
      <div class="valor">${miles(iteraciones.count)}</div></div>
    <div class="tarjeta"><div class="rotulo">Tasa de error</div>
      <div class="valor">${((fallidas.rate || 0) * 100).toFixed(2)} %</div></div>
    <div class="tarjeta"><div class="rotulo">Datos recibidos</div>
      <div class="valor">${bytes(recibidos)}</div></div>
  </div>

  <h2>Tiempos de respuesta por tipo de operación</h2>
  <table>
    <tr><th>Operación</th><th class="num">Media</th><th class="num">Mediana</th>
        <th class="num">P95</th><th class="num">Máximo</th><th class="num">Umbral</th>
        <th>Resultado</th></tr>
    ${filaTrend("Consultas", consulta, 1500)}
    ${filaTrend("Escrituras", escritura, 3000)}
  </table>
  <p class="nota">Umbrales de RNF-01: P95 inferior a 1,5 s en consultas y a 3 s en escrituras.</p>

  <h2>Verificaciones por endpoint</h2>
  <table>
    <tr><th>Verificación</th><th class="num">Conformes</th><th class="num">Fallidas</th>
        <th class="num">Porcentaje</th></tr>
    ${filasChecks(data.root_group)}
  </table>

  <h2>Volumen de datos de la medición</h2>
  <p class="nota">La carga inicial crea el conjunto sobre el que se mide, porque sobre tablas
     vacías los tiempos no son representativos: un proyecto, ${SUBPROYECTOS} subproyectos,
     ${TAREAS} tareas, una asignación por tarea, ${BITACORAS} registros de bitácora y una
     línea base congelada.</p>
  <p class="nota">Los listados no están paginados en el servidor, de modo que el volumen
     transferido crece con el número de filas. El grupo de escrituras inserta una variación
     por iteración, por lo que la tabla crece durante la propia corrida.</p>
</main>
</body>
</html>`;

  const linea = (rotulo, metrica, umbral) => {
    if (!metrica) return `  ${rotulo}: sin datos`;
    const p95 = metrica.values["p(95)"];
    const estado = p95 < umbral ? "CUMPLE" : "NO CUMPLE";
    return `  ${rotulo}: P95 ${ms(p95)} (umbral ${ms(umbral)}) -> ${estado}`;
  };

  const consola = [
    "",
    `${titulo}  ·  ${vus} usuarios virtuales durante ${duracion}`,
    linea("Consultas ", consulta, 1500),
    linea("Escrituras", escritura, 3000),
    `  Peticiones: ${miles(peticiones.count)} a ${miles(peticiones.rate)}/s · ` +
      `error ${((fallidas.rate || 0) * 100).toFixed(2)} % · recibidos ${bytes(recibidos)}`,
    `  Informe: ${salida}`,
    "",
  ].join(String.fromCharCode(10));

  return { [salida]: html, stdout: consola };
}
