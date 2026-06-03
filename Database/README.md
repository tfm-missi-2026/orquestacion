# Database — capa de persistencia

Esta carpeta cumple dos funciones:

1. **Bootstrap del cluster PostgreSQL** (`init/`). Al primer arranque del
   contenedor `postgres`, Docker ejecuta automáticamente los scripts de
   `init/` montados en `/docker-entrypoint-initdb.d`. Se crean las tres
   bases lógicas y los usuarios de aplicación.

2. **Copia legible de las migraciones Flyway** (`spsrt_*/migrations/`). El
   sistema en ejecución usa los archivos `V*.sql` que viven **dentro** de
   cada microservicio Spring Boot (`Backend/<ms>/src/main/resources/db/migration`).
   Esta copia paralela sirve como entregable independiente para la memoria
   del TFM y para revisión humana sin tener que entrar al árbol Maven.

## Convención de sincronización

Cada vez que se añade o modifica una migración Flyway en un microservicio,
se replica idéntica en `Database/<bd>/migrations/`. La regla es estricta:
**los dos archivos tienen el mismo contenido byte a byte**.

## Estructura

```
Database/
├── init/
│   └── 00_create_databases.sql        # crea las 3 BD y sus usuarios
├── spsrt_administracion/
│   └── migrations/
│       └── V*.sql                     ← réplica de Backend/ms-administracion/...
├── spsrt_proyectos/
│   └── migrations/
│       └── V*.sql                     ← réplica de Backend/ms-proyectos/...
└── spsrt_seguimiento/
    └── migrations/
        └── V*.sql                     ← réplica de Backend/ms-seguimiento/...
```
