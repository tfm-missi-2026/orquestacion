# SPSRT — Orquestación y despliegue

Repositorio de **orquestación** del sistema **SPSRT — Sistema de Planificación y
Seguimiento de Recursos Técnicos** (UNIR, MISSI). Reúne el `docker-compose.yml` del
stack completo, el init/migraciones de base de datos y la documentación de arranque.
El código de cada componente vive en su **propio repositorio**.

> Estado: **Backend funcional.** Los 5 servicios arrancan y los 3 microservicios de
> negocio exponen sus APIs REST completas (auth/JWT, CRUDs y cálculos) documentadas en
> Swagger. El **frontend aún no consume las APIs** (no tiene capa HTTP todavía).

## Componentes del stack

| Componente | Repo | Tecnología | Puerto | Responsable |
|---|---|---|---|---|
| `eureka-server` | `eureka-server` | Spring Cloud Netflix Eureka | 8761 | colaborativo |
| `api-gateway` | `api-gateway` | Spring Cloud Gateway + JWT | 8080 | colaborativo |
| `ms-administracion` | `ms-administracion` | Spring Boot · PostgreSQL · Flyway | 8081 | EFPF |
| `ms-proyectos` | `ms-proyectos` | Spring Boot · PostgreSQL · Flyway | 8082 | MJPA |
| `ms-seguimiento` | `ms-seguimiento` | Spring Boot · PostgreSQL · Flyway | 8083 | PESSL |
| `postgres` | (imagen) | PostgreSQL 16 (3 BD lógicas) | 5432 | — |
| `frontend` | `frontend` | Angular 21 + TailAdmin + pnpm 11.3.0 | 4200 | colaborativo |

## Disposición esperada del workspace

Este repo construye cada servicio desde `../Backend/<servicio>` y `../Frontend`, por lo
que **los repos de servicio se clonan como hermanos** en esta estructura:

```
<workspace>/
├── orquestacion/        # este repo (docker-compose.yml + Database/ + .env.example)
├── Backend/
│   ├── eureka-server/
│   ├── api-gateway/
│   ├── ms-administracion/
│   ├── ms-proyectos/
│   └── ms-seguimiento/
└── Frontend/            # repo frontend (Angular)
```

### Clonado inicial

```bash
mkdir spsrt && cd spsrt
git clone https://github.com/tfm-missi-2026/orquestacion.git
mkdir Backend
git clone https://github.com/tfm-missi-2026/eureka-server.git     Backend/eureka-server
git clone https://github.com/tfm-missi-2026/api-gateway.git       Backend/api-gateway
git clone https://github.com/tfm-missi-2026/ms-administracion.git Backend/ms-administracion
git clone https://github.com/tfm-missi-2026/ms-proyectos.git      Backend/ms-proyectos
git clone https://github.com/tfm-missi-2026/ms-seguimiento.git    Backend/ms-seguimiento
git clone https://github.com/tfm-missi-2026/frontend.git          Frontend
```

## Requisitos previos

- Docker Desktop 24+ con docker compose v2 — **único requisito para levantar todo el backend
  + PostgreSQL** (cada microservicio se compila dentro de su contenedor; no hace falta Java/Maven local)
- Node.js 20.19.x LTS · pnpm 11.3.0 (`npm install -g pnpm@11.3.0`) — solo para el frontend
- Java 21 + Maven 3.9+ — opcional, solo si se quiere compilar un microservicio fuera del contenedor

## Primer arranque (stack completo)

```bash
cd orquestacion
cp .env.example .env
docker compose up -d --build
```

La primera vez tarda ~5 minutos (descarga de imágenes base + build Maven).

### Verificación rápida

| URL | Resultado esperado |
|---|---|
| http://localhost:8761 | dashboard Eureka con los 3 microservicios y el gateway registrados |
| http://localhost:8080/actuator/health | `{"status":"UP"}` |
| http://localhost:8081/actuator/health · :8082 · :8083 | `{"status":"UP"}` |
| http://localhost:8081/swagger-ui.html · :8082 · :8083 | Swagger UI con los endpoints de cada microservicio |

> El **login** entra por el gateway: `POST http://localhost:8080/api/auth/login`.
> Usuario administrador semilla (cargado por `Database/spsrt_administracion/migrations/V2__seed.sql`):
>
> ```json
> { "email": "admin@srp.local", "contrasenia": "Admin123" }
> ```
>
> Devuelve un JWT que se envía como `Authorization: Bearer <token>` en el resto de endpoints.

### Frontend en local

```bash
cd Frontend
pnpm install
pnpm dev        # alias de `ng serve` (también existe `pnpm start`)
```

`http://localhost:4200` → plantilla TailAdmin con el design-system propio (`src/app/ui/`).
Todavía **no consume el backend** (sin capa HTTP/auth aún), así que las APIs se prueban por
Swagger o con la colección Bruno; ambos flujos funcionan de forma independiente al frontend.

## Levantar un solo microservicio (standalone)

Cada repo de microservicio trae su **propio** `docker-compose.yml` que levanta solo ese
servicio + su PostgreSQL (sin Eureka), para desarrollo aislado:

```bash
cd Backend/ms-seguimiento
cp .env.example .env
docker compose up -d --build
```

## Pruebas de API (Bruno)

La carpeta [`Test/`](Test/) es una colección de [Bruno](https://www.usebruno.com/) que cubre
**todos los endpoints** de los 3 microservicios por el gateway (~76 requests), encadenados:
login (guarda el JWT) + CRUD completo + casos negativos (401 sin token, 401 login inválido,
409 de sobrecarga) + limpieza final. Las carpetas están numeradas para fijar el orden de
ejecución: `1 Salud · 2 Auth · 3 Administracion · 4 Proyectos · 5 Seguimiento · 6 Limpieza`.

En Bruno: *Open Collection* → `orquestacion/Test/`, selecciona el environment **Local** y usá
el **Collection Runner** sobre la colección `SPSRT` (corre las carpetas en orden y genera un
reporte HTML). Detalle de orden y variables en [`Test/00_LEEME.md`](Test/00_LEEME.md).

## Convenciones

- **Multi-repo**: 6 repos de servicio + este repo de orquestación. Cada microservicio es
  un proyecto Maven independiente (sin parent POM común); subir la versión de Spring Boot
  se hace en cada `pom.xml` por separado.
- **JWT compartido HS256** vía `JWT_SECRET` para M0. En M4 se evaluará migrar a RS256 con
  JWKS publicado por `ms-administracion`.
- **Migraciones Flyway** dentro de cada microservicio (`src/main/resources/db/migration/V*.sql`);
  se replican en `Database/spsrt_*/migrations/` (este repo) para revisión humana y entrega
  académica. La creación de las 3 BD/usuarios la hace `Database/init/00_create_databases.sql`
  al levantar postgres.
- **Paquete Java raíz**: `pe.unir.tfm.srp.<dominio>`.
- El **`.env` real no se versiona** (está en `.gitignore`); se parte de `.env.example`.

## Hitos

- **M1** — Autenticación (login + JWT en backend) — ✅ hecho (falta el guard Angular del lado front)
- **M2** — Modelo de datos completo por microservicio — ✅ hecho (DDL + seed vía Flyway)
- **M3** — APIs CRUD por entidad principal — ✅ hecho (44 endpoints REST en los 3 ms)
- **M4** — Integración entre microservicios — parcial (cruce por UUID; sin llamadas backend-backend)
- **M5** — Frontend conectado a las APIs — ⏳ pendiente (falta la capa HTTP/servicios en Angular)
- **M6** — Despliegue completo y evaluación — ⏳ pendiente
