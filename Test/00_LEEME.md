# Colección Bruno — SPSRT (pruebas funcionales de API por el gateway)

Pruebas funcionales de **todos los endpoints** de los tres microservicios, ejecutadas
contra el **API Gateway** (`http://localhost:8080`). Cada request valida su código HTTP
y la forma de la respuesta con un bloque `tests {}`.

## Requisitos

1. Levantar el stack: `cd orquestacion && docker compose up -d --build`.
2. Seleccionar el *environment* **Local** en Bruno.
3. Tener el seed cargado (usuario `admin@srp.local` / `Admin123`).

## Orden de ejecución (importante)

La colección está **encadenada** (cada `POST` guarda IDs en variables que usan los
siguientes). Ejecutar **carpeta por carpeta en este orden**:

1. **Salud** — health del gateway (sin auth).
2. **Auth** — `Login` (guarda `{{token}}`) + negativos (401).
3. **Administracion** — `Listar catalogo` **captura los UUID del catálogo** (necesarios
   para Proyectos y Seguimiento) + CRUD de catálogo/roles/módulos/usuarios.
4. **Proyectos** — crea proyecto → subproyecto → tarea (guarda `{{proyectoId}}`,
   `{{subproyectoId}}`, `{{tareaId}}`).
5. **Seguimiento** — asignación (incluye el caso **409** de sobrecarga, RF-06),
   bitácora, línea base, avance, carga y variación.
6. **Limpieza** — `DELETE` de todo lo creado, en orden hijo → padre.

> Si se ejecuta toda la colección de una vez, mantener este orden de carpetas. Las
> variables se conservan durante la corrida.

## Variables

- `token` — JWT, lo setea `Auth/Login`.
- `adminUserId`, `rol*`, `mod*` — UUID deterministas del seed (en el environment).
- `cat*` — UUID del catálogo, capturados por `Administracion/Listar catalogo`.
- `proyectoId`, `subproyectoId`, `tareaId`, `asignacionId`, `bitacoraId`,
  `actividadId`, `lineaBaseId`, `variacionId`, `createdRolId`, `createdModuloId`,
  `createdUsuarioId`, `catalogoId` — capturados por sus respectivos `POST`.

*Fuente. Elaboración propia.*
