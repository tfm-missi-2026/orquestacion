# Test — Colección Bruno (SPSRT)

Colección de [Bruno](https://www.usebruno.com/) para probar la API del sistema SPSRT a través
del **API Gateway** (`http://localhost:8080`).

## Cómo usar

1. Levanta el stack: `cd Development/orquestacion && docker compose up -d --build`.
2. En Bruno: **Open Collection** → selecciona esta carpeta `Test/`.
3. Selecciona un environment que defina `tfm-api-gateway-local` = `http://localhost:8080`
   (el environment **Local** incluido ya lo trae; también sirve tu environment global **TFM**).
4. Ejecuta **Auth → Login** primero: guarda el JWT en la variable de runtime `{{token}}`.
5. Ya puedes ejecutar el resto de requests (usan `Authorization: Bearer {{token}}`).

## Credenciales (seed)

- Usuario: `admin@srp.local`
- Clave: `Admin123`

## Estructura

- **Auth/Login** — `POST /api/auth/login` (guarda el token en `{{token}}`).
- **Administracion** — usuarios, mi usuario, roles, módulos, catálogo.
- **Proyectos** — proyectos, tareas.
- **Seguimiento** — asignaciones, actividades, variaciones, mi bitácora.
- **Salud/Gateway health** — `/actuator/health` (público, sin token).

> Sin el token, los endpoints de negocio devuelven **401** (es lo correcto: el gateway exige
> JWT salvo en `/api/auth/**` y `/actuator/**`).

## Versionado

Esta colección vive dentro del repo **`orquestacion`** (`orquestacion/Test/`), así que se
versiona y se comparte con el equipo al clonar ese repo. Las colecciones Bruno son archivos
`.bru` en texto plano, *git-friendly*.
