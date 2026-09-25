# Colección Bruno — SPSRT (pruebas funcionales de API por el gateway)

Pruebas funcionales de los endpoints de los tres microservicios, ejecutadas **contra el API
Gateway** (`http://localhost:8080`). Cada petición valida su código HTTP y la forma de la
respuesta con un bloque `tests {}`.

**84 peticiones · 165 verificaciones automáticas.**

| Grupo | Peticiones | Cubre |
|---|---:|---|
| 1 Salud | 1 | Health del gateway y generación del identificador de corrida |
| 2 Auth | 2 | Login y usuario autenticado (CU-01) |
| 3 Catalogos | 3 | Resolución dinámica de los UUID que usa el resto de la colección |
| 4 Administracion | 21 | Catálogo, roles, módulos y usuarios (CU-02) |
| 5 Proyectos | 12 | Proyectos, subproyectos y tareas (CU-03) |
| 6 Seguimiento | 25 | Asignaciones (CU-04), carga (CU-05), bitácora (CU-06), avance (CU-07) y variaciones (CU-08) |
| 7 Negativos | 6 | Rechazos esperados: credenciales, sin token, formato inválido, inexistente, validación y regla de página de inicio |
| 8 Limpieza | 14 | Borrado lógico en orden hijo a padre y verificación de que el registro deja de ser accesible |

## Requisitos

1. Levantar el stack: `cd orquestacion && docker compose up -d --build`.
2. Seleccionar el *environment* **Local** en Bruno.
3. El seed se carga solo con Flyway al arrancar (`admin@srp.local` / `Admin123`).

## Ejecución

Desde Bruno, carpeta por carpeta **en orden numérico**, o completa con el runner. Desde
línea de comandos, sin instalar nada:

```bash
cd orquestacion/Test
npx @usebruno/cli run --env Local -r
```

El orden importa: la colección está **encadenada**, cada `POST` guarda identificadores que
consumen las peticiones siguientes.

## Manejo dinámico de variables

La colección **no fija ningún UUID a mano** y **se puede reejecutar sin resetear la base**.

**Environment mínimo.** `Local.bru` solo define `baseUrl`, `adminEmail` y `adminPassword`.
Ningún identificador del seed está escrito en el environment, de modo que un cambio en los
datos semilla no rompe las pruebas.

**Todo se resuelve por API.** `Auth/Login` captura `adminUserId` y `adminRolId` de la propia
respuesta del login. `Catalogos/Resolver catalogo` recorre `/api/catalogo` y resuelve los
nueve UUID que la colección necesita buscándolos por grupo y opción.
`Catalogos/Resolver roles y modulos` captura el rol de recurso técnico por su código y una
página de inicio válida.

**Identificador único de corrida.** La primera petición fija `runId` con un timestamp en
base 36. Todo lo que la colección crea lo lleva como sufijo: `QA_ROL_{{runId}}`,
`QA_MOD_{{runId}}`, `qa.{{runId}}@srp.local`, `QA-{{runId}}`. Así no colisiona con el seed ni
con corridas anteriores.

**Lectura tolerante a la paginación.** Los listados que devuelven `{items, total, ...}` se
leen como `res.body.items || res.body`, de modo que un cambio en la forma de la respuesta no
invalida las verificaciones de contenido.

### Variables que se capturan en tiempo de ejecución

| Variable | La captura |
|---|---|
| `runId` | `Salud/Gateway health` |
| `token`, `adminUserId`, `adminRolId` | `Auth/Login` |
| `catTipoSubproyecto`, `catPrioridad`, `catSituacionPendiente`, `catSituacionCulminado`, `catTipoVariacion`, `catSitVarPendiente`, `catSitVarAprobada`, `catTipoActividad`, `catModalidad` | `Catalogos/Resolver catalogo` |
| `rolRecursoId`, `rolGestorId`, `paginaInicioId` | `Catalogos/Resolver roles y modulos` |
| `moduloSeccion` | `Administracion/Listar modulos` |
| `catalogoId`, `rolCreadoId`, `moduloCreadoId`, `usuarioCreadoId` | sus respectivos `POST` |
| `proyectoId`, `subproyectoId`, `tareaId` | sus respectivos `POST` |
| `asignacionId`, `asignacionSobrecargaId`, `actividadId`, `bitacoraId`, `bitacoraActividadId`, `lineaBaseId`, `variacionId` | sus respectivos `POST` |

## Reglas de negocio que se verifican

- **Capacidad del recurso (RF-06).** `Sobrecarga rechazada` comprueba el 409 cuando las horas
  superan la capacidad del periodo, y `Sobrecarga confirmada` que la operación procede cuando
  el cliente envía `confirmarSobrecarga`.
- **Asignación duplicada.** Rechazo con 409 al repetir tarea y recurso.
- **Página de inicio del rol.** No se puede quitar de los módulos del rol el que está
  configurado como página de inicio.
- **Borrado lógico.** Tras eliminar, el recurso responde 404 y la fila conserva su historial
  con `estado = 0`.
- **Contrato de errores.** Los casos negativos verifican los códigos RFC 7807:
  `CREDENCIALES_INVALIDAS`, `VALIDACION_FALLIDA`, `RECURSO_NO_ENCONTRADO` y
  `CONFLICTO_NEGOCIO`.

*Fuente. Elaboración propia.*
