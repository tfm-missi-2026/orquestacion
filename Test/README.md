# Test — Colección Bruno (SPSRT)

Colección de [Bruno](https://www.usebruno.com/) que prueba **todos los endpoints** de la API
del sistema SPSRT a través del **API Gateway** (`http://localhost:8080`). Son ~76 requests
encadenados (cada `POST` guarda IDs en variables que usan los siguientes) que cubren el CRUD
de los 3 microservicios, los casos negativos de seguridad/negocio y la limpieza final.

Cada request valida su código HTTP y la forma de la respuesta con un bloque `tests {}` (chai).

## Cómo usar

1. Levanta el stack: `cd Development/orquestacion && docker compose up -d --build`.
2. En Bruno: **Open Collection** → selecciona esta carpeta `Test/`.
3. Selecciona el environment **Local** (define `tfm-api-gateway-local` = `http://localhost:8080`
   más los UUID deterministas del seed).
4. Ejecútala con el **Collection Runner** (clic derecho en la colección `SPSRT` → *Run*), que
   recorre las carpetas en orden y produce un reporte HTML. También puedes correr request por
   request, empezando por **2 Auth → Login** (guarda el JWT en `{{token}}`).

> La colección está **encadenada**: respeta el orden de carpetas. Si la corres sobre una BD ya
> usada, conviene resetear (`docker compose down -v && docker compose up -d --build`) para que
> los `POST` no choquen con filas en *soft-delete* (las claves únicas se conservan).

## Credenciales (seed)

- Usuario: `admin@srp.local`
- Clave: `Admin123`

## Estructura (orden de ejecución)

1. **1 Salud** — `GET /actuator/health` del gateway (público, sin token).
2. **2 Auth** — `Login` (guarda `{{token}}`) + negativos: login inválido (401) y acceso sin
   token (401).
3. **3 Administracion** — `Listar catalogo` **captura los UUID del catálogo** (necesarios para
   Proyectos y Seguimiento) + CRUD de catálogo, roles, módulos y usuarios.
4. **4 Proyectos** — proyecto → subproyecto → tarea (guarda `{{proyectoId}}`,
   `{{subproyectoId}}`, `{{tareaId}}`).
5. **5 Seguimiento** — asignación (incluye el caso **409** de sobrecarga, RF-06), actividades,
   bitácora, línea base, avance, carga y variaciones (con su resolución).
6. **6 Limpieza** — `DELETE` de todo lo creado, en orden hijo → padre.

## Casos negativos cubiertos

- **401** — acceso a endpoint protegido sin token.
- **401** — login con credenciales inválidas.
- **409 `CONFLICTO_NEGOCIO`** — asignación que deja al recurso en sobrecarga (RF-06).

> Sin token, los endpoints de negocio devuelven **401** (es lo correcto: el gateway exige JWT
> salvo en `/api/auth/**` y `/actuator/**`).

## Versionado

Esta colección vive dentro del repo **`orquestacion`** (`orquestacion/Test/`), así que se
versiona y se comparte con el equipo al clonar ese repo. Las colecciones Bruno son archivos
`.bru` en texto plano, *git-friendly*.
