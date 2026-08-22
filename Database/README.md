# Database — capa de persistencia

Esta carpeta tiene una única función:

**Bootstrap del cluster PostgreSQL** (`init/`). Al primer arranque del
contenedor `postgres`, Docker ejecuta automáticamente los scripts de
`init/` montados en `/docker-entrypoint-initdb.d`. Se crean las tres
bases lógicas y los usuarios de aplicación.

## Estructura

```
Database/
└── init/
    └── 00_create_databases.sql        # crea las 3 BD y sus usuarios
```

## Migraciones (fuente única)

Las migraciones Flyway viven **solo** dentro de cada microservicio, en
`<ms>/src/main/resources/db/migration/V*.sql`, y las ejecuta cada
microservicio al arrancar (`spring.flyway.locations: classpath:db/migration`).

- `ms-administracion` → BD `spsrt_administracion`
- `ms-proyectos` → BD `spsrt_proyectos`
- `ms-seguimiento` → BD `spsrt_seguimiento`

No mantener copias duplicadas de migraciones en `orquestacion/`: el árbol
Maven de cada MS es la única fuente de verdad para el esquema.