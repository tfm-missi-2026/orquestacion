# SPSRT - Guia para levantar el proyecto en local

Guia operativa para levantar el sistema **SPSRT** en un entorno de desarrollo local.
Se describen tres modalidades segun que tanto se ejecute fuera de Docker.

En **las tres modalidades PostgreSQL corre en Docker** y el **frontend Angular corre en
local** con `pnpm dev` (el `docker-compose.yml` todavia no incluye un servicio para el
frontend; se agregara en M6).

| Modo | Backend | Cuando conviene |
|------|---------|-----------------|
| **A - Todo local** | Los 5 servicios corren en el host (IntelliJ o Maven) | Hay que debuggear el gateway, `ms-administracion` o mas de un servicio a la vez |
| **B - Hibrido** | Solo `ms-seguimiento` en el host; el resto en Docker | Trabajo enfocado en un microservicio (caso tipico del dia a dia) |
| **C - Todo en Docker** | Los 5 servicios en contenedores, incluido `ms-seguimiento` | Validar el sistema completo, hacer una demo, o verificar que algo funciona igual que en un despliegue |

Recomendacion: arrancar con el **Modo C** para comprobar que todo el circuito responde, y
pasar al **Modo B** cuando toque desarrollar.

---

## 1. Requisitos previos

| Herramienta | Version | Verificacion |
|-------------|---------|--------------|
| Docker Desktop | 24+ con compose v2 | `docker --version` |
| JDK | 17 o superior (verificado con Temurin 21) | `java -version` |
| Node | 24.18.0 (fijado en `.nvmrc`) | `node -v` |
| pnpm | 11.3.0 (via corepack) | `pnpm -v` |
| Maven | wrapper incluido (`mvnw.cmd`) | no requiere instalacion |

No hace falta Maven instalado: cada microservicio trae su wrapper. En el **Modo C** tampoco
hace falta JDK: cada servicio se compila dentro de su contenedor.

### Disposicion del workspace

```
Development/
├── Backend/
│   ├── eureka-server/
│   ├── api-gateway/
│   ├── ms-administracion/
│   ├── ms-proyectos/
│   └── ms-seguimiento/
├── Frontend/
└── orquestacion/
```

Si los repos estan clonados con otra estructura (por ejemplo, como hermanos directos de
`orquestacion`, sin la carpeta `Backend/` intermedia), definir `BACKEND_ROOT` en el `.env`.
El `docker-compose.yml` la usa en el `build.context` de los 5 servicios:

```yaml
context: ${BACKEND_ROOT:-../Backend}/<servicio>
```

Para ver como resuelve en cada maquina: `docker compose config`.

### Puertos

| Servicio | Puerto |
|----------|--------|
| PostgreSQL | 5432 |
| Eureka | 8761 |
| API Gateway | 8080 |
| ms-administracion | 8081 |
| ms-proyectos | 8082 |
| ms-seguimiento | 8083 |
| Frontend Angular | 4200 |

---

## 2. Preparacion comun

Se hace una sola vez y sirve para las tres modalidades.

### 2.1 Archivo `.env` de orquestacion

```powershell
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\orquestacion"
Copy-Item .env.example .env
```

El `.env` no se versiona. Define las credenciales de las 3 bases y el `JWT_SECRET`
compartido por el gateway y los microservicios.

### 2.2 Node con fnm y el `.nvmrc`

El repo `frontend` fija su version de Node en el archivo **`.nvmrc`** de la raiz:

```
24.18.0
```

Ese archivo lo leen tanto `fnm` como `nvm`, asi que los tres integrantes trabajan con la
misma version sin coordinarlo a mano. La version de **pnpm** la fija el campo
`packageManager` del `package.json` (`pnpm@11.3.0`) y la resuelve corepack.

#### Inicializar fnm en el shell

fnm no pone Node en el PATH por si solo: hay que inicializarlo en cada shell. **Esta
configuracion es por shell, no por proyecto**, y es la causa habitual de que `node` o `pnpm`
respondan `command not found` aunque fnm este instalado.

**PowerShell** — agregarlo al perfil para que quede permanente:

```powershell
if (!(Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }
Add-Content $PROFILE 'fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression'
. $PROFILE
```

**Git Bash** — la equivalente, en `~/.bashrc`:

```bash
echo 'eval "$(fnm env --use-on-cd --shell bash)"' >> ~/.bashrc
echo '[ -f ~/.bashrc ] && . ~/.bashrc' >> ~/.bash_profile
source ~/.bashrc
```

Los dos archivos hacen falta en Git Bash porque bash carga uno u otro segun como arranque:
`~/.bashrc` en shells interactivos no-login, `~/.bash_profile` cuando es login shell.

El flag `--use-on-cd` es lo que hace que fnm cambie de version automaticamente al entrar a
una carpeta con `.nvmrc`.

#### Instalar la version del proyecto

```powershell
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\Frontend"
fnm install
node -v
```

`fnm install` sin argumentos toma la version del `.nvmrc`. `node -v` debe devolver
**v24.18.0**.

Si devuelve otra version, el `--use-on-cd` no se disparo: salir y volver a entrar a la
carpeta (`cd ..` y `cd Frontend`), o forzarlo con `fnm use`, que tambien lee el `.nvmrc`.

Comandos utiles de fnm:

| Comando | Que hace |
|---------|----------|
| `fnm list` | Versiones instaladas y cual esta activa |
| `fnm install` | Instala la version del `.nvmrc` de la carpeta actual |
| `fnm use` | Activa la version del `.nvmrc` en la sesion actual |
| `fnm default 24.18.0` | Deja esa version como la de arranque de cualquier shell |

### 2.3 Dependencias del frontend

```powershell
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\Frontend"
node -v
corepack enable
pnpm install
```

**corepack** viene incluido con Node y esta desactivado por defecto: `corepack enable` crea
los shims de `pnpm`. Con corepack activo, `pnpm` usa automaticamente la version declarada en
`packageManager`, sin instalacion global.

`corepack enable` se corre **una vez por cada version de Node** que maneje fnm: cada
instalacion trae su propio corepack. Si se cambia de version de Node y `pnpm` deja de
responder, volver a habilitarlo en esa version.

---

## 3. Modo A - Todo local

Solo PostgreSQL en Docker. Los 5 servicios Spring Boot corren en el host.

> **No hay que configurar variables de entorno ni VM options.** Los `application.yml` ya
> traen los defaults que este modo necesita:
>
> ```yaml
> url: ${DB_URL:jdbc:postgresql://localhost:5432/spsrt_<dominio>}
> defaultZone: ${EUREKA_DEFAULT_ZONE:http://localhost:8761/eureka/}
> secret: ${JWT_SECRET:cambiar-esta-clave-en-produccion-minimo-32-bytes-aleatorios}
> ```
>
> Como los 4 servicios caen en el mismo `JWT_SECRET` por defecto, los tokens que emite
> `ms-administracion` los validan los demas sin sincronizar nada.
>
> Las VM options `eureka.instance.hostname=host.docker.internal` son **exclusivas del
> Modo B**: aca el gateway tambien corre en el host y no hacen falta. Si la Run
> Configuration de `ms-seguimiento` las tiene puestas de un uso anterior en Modo B,
> quitarlas.

### 3.1 PostgreSQL

```powershell
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\orquestacion"
docker compose up -d postgres
docker compose ps
```

Esperar a que el contenedor `spsrt-postgres` figure **healthy**. El script
`Database/init/00_create_databases.sql` crea las 3 bases con sus usuarios.

### 3.2 Servicios Spring Boot

**Orden de arranque.** Eureka primero, el gateway al final:

| # | Servicio | Puerto | Por que en esa posicion |
|---|----------|--------|-------------------------|
| 1 | `eureka-server` | 8761 | El resto se registra contra el; debe estar arriba antes que los demas |
| 2 | `ms-administracion` | 8081 | Emite los JWT del login |
| 3 | `ms-proyectos` | 8082 | Servicio de dominio |
| 4 | `ms-seguimiento` | 8083 | Servicio de dominio |
| 5 | `api-gateway` | 8080 | Rutea por descubrimiento: conviene que los destinos ya esten registrados |

Esperar a que Eureka responda en http://localhost:8761 antes de lanzar el resto. Si se
arranca alguno antes, igual funciona: el cliente reintenta el registro en background, pero
tarda mas en aparecer en el dashboard.

```powershell
# Terminal 1
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\Backend\eureka-server"
.\mvnw spring-boot:run

# Terminal 2 (esperar a que Eureka responda en 8761)
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\Backend\ms-administracion"
.\mvnw spring-boot:run

# Terminal 3
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\Backend\ms-proyectos"
.\mvnw spring-boot:run

# Terminal 4
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\Backend\ms-seguimiento"
.\mvnw spring-boot:run

# Terminal 5
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\Backend\api-gateway"
.\mvnw spring-boot:run
```

### 3.3 Alternativa en IntelliJ

1. Abrir `Development\Backend` como proyecto.
2. **Add Maven Project** por cada uno de los 5 `pom.xml` (son proyectos Maven
   independientes, sin parent POM comun).
3. Crear una Run Configuration de tipo **Spring Boot** por servicio, **sin variables de
   entorno y sin VM options**: los defaults del `application.yml` resuelven todo.
4. Habilitar **annotation processing**
   (`Ctrl+Alt+S > Build, Execution, Deployment > Compiler > Annotation Processors`). Aplica
   a los 5: el proyecto usa Lombok y MapStruct, y sin eso IntelliJ marca errores falsos de
   `cannot find symbol` en codigo que compila bien con Maven.
5. Crear una configuracion **Compound** (`Run > Edit Configurations > + > Compound`)
   que agrupe las 5. Arranca todo con un click.

La Compound no garantiza el orden de arranque. Si el dashboard de Eureka tarda en mostrar
los servicios, lanzarlos a mano en el orden de la tabla de 3.2.

Se puede dejar `ms-seguimiento` en modo debug y las otras cuatro en run normal.

### 3.4 Frontend

```powershell
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\Frontend"
pnpm dev
```

---

## 4. Modo B - Hibrido

Todo en Docker menos `ms-seguimiento`, que corre en el host desde IntelliJ.

### 4.1 Stack sin ms-seguimiento

```powershell
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\orquestacion"
docker compose up -d --build postgres eureka-server api-gateway ms-administracion ms-proyectos
```

Al nombrar los servicios explicitamente, compose levanta solo esos y el puerto 8083 queda
libre. La primera vez tarda unos minutos por el build de Maven dentro de los contenedores.

Si el stack completo ya estaba corriendo (Modo C), basta con detener ese contenedor:

```powershell
docker compose stop ms-seguimiento
```

### 4.2 ms-seguimiento en IntelliJ

**Run > Edit Configurations > + > Spring Boot**

- **Main class:** `pe.unir.tfm.srp.seguimiento.MsSeguimientoApplication`
- **JDK:** 21

**Environment variables:**

```
SERVER_PORT=8083;DB_URL=jdbc:postgresql://localhost:5432/spsrt_seguimiento;DB_USER=spsrt_seguimiento_user;DB_PASSWORD=spsrt_seguimiento_pwd;EUREKA_DEFAULT_ZONE=http://localhost:8761/eureka/;JWT_SECRET=<mismo valor que orquestacion\.env>
```

**VM options:**

```
-Deureka.instance.prefer-ip-address=false -Deureka.instance.hostname=host.docker.internal
```

Habilitar ademas **annotation processing**
(`Ctrl+Alt+S > Build, Execution, Deployment > Compiler > Annotation Processors`). El
proyecto usa Lombok y MapStruct; sin eso IntelliJ marca errores falsos de
`cannot find symbol` en codigo que compila bien con Maven.

### 4.3 Alternativa por terminal

```powershell
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\Backend\ms-seguimiento"
$env:JWT_SECRET="<mismo valor que orquestacion\.env>"
.\mvnw spring-boot:run "-Dspring-boot.run.jvmArguments=-Deureka.instance.prefer-ip-address=false -Deureka.instance.hostname=host.docker.internal"
```

Las demas variables no hacen falta: los defaults del `application.yml` ya apuntan a
`localhost:5432` y `localhost:8761`.

### 4.4 Por que las VM options

El API Gateway rutea por descubrimiento (`uri: lb://ms-seguimiento`), o sea que le pregunta
a Eureka en que direccion esta el servicio.

En este modo el gateway corre **dentro** de Docker y `ms-seguimiento` **fuera**. El
`application.yml` trae `eureka.instance.prefer-ip-address: true`, con lo cual el servicio se
registraria con la IP LAN del host, que desde un contenedor no siempre resuelve (depende de
VPN, adaptadores virtuales, Hyper-V).

El sintoma cuando falla es enganoso: el servicio aparece **UP** en el dashboard de Eureka
pero el gateway devuelve **503**.

`host.docker.internal` es el nombre que Docker Desktop resuelve siempre desde el contenedor
hacia el host. Va como VM option y no en el `application.yml` porque ese archivo es
compartido y dentro del contenedor necesita el comportamiento original.

### 4.5 El JWT_SECRET debe coincidir

El login lo atiende `ms-administracion` (contenedor), que firma el token con el `JWT_SECRET`
del `.env`. `ms-seguimiento` en local lo valida con el suyo. Si no son identicos, todos los
endpoints protegidos responden **401** y el error parece de permisos cuando en realidad es de
configuracion.

En los modos A y C este problema no existe: todos los servicios toman el mismo valor.

### 4.6 Frontend

```powershell
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\Frontend"
pnpm dev
```

---

## 5. Modo C - Todo en Docker

Los 5 servicios y PostgreSQL en contenedores. Es la modalidad mas simple: un solo comando y
ninguna variable que sincronizar a mano.

### 5.1 Levantar el stack completo

```powershell
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\orquestacion"
docker compose up -d --build
docker compose ps
```

La primera vez tarda unos 5 minutos: descarga las imagenes base y compila los 5 servicios
con Maven dentro de los contenedores. Los 6 contenedores deben quedar en estado `Up`:

```
spsrt-postgres            Up (healthy)   5432
spsrt-eureka              Up (healthy)   8761
spsrt-gateway             Up             8080
spsrt-ms-administracion   Up             8081
spsrt-ms-proyectos        Up             8082
spsrt-ms-seguimiento      Up             8083
```

Flyway aplica las migraciones de cada dominio al arrancar su servicio.

### 5.2 Frontend

```powershell
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\Frontend"
pnpm dev
```

### 5.3 Cuando hay cambios de codigo

Los contenedores traen el codigo compilado al momento del build, asi que un cambio en el
fuente no se refleja hasta reconstruir la imagen de ese servicio:

```powershell
docker compose up -d --build ms-seguimiento
```

Ese ciclo de rebuild es la razon por la que el Modo C no sirve para desarrollar: para eso
estan los modos A y B.

---

## 6. Cambiar de modo

No hace falta bajar todo para pasar de una modalidad a otra.

| De | A | Como |
|----|---|------|
| C | B | `docker compose stop ms-seguimiento` y arrancar el servicio en IntelliJ |
| B | C | Detener la instancia local y `docker compose up -d ms-seguimiento` |
| C | A | `docker compose stop eureka-server api-gateway ms-administracion ms-proyectos ms-seguimiento` y arrancar los 5 en el host |
| A | C | Detener los procesos locales y `docker compose up -d` |

Al pasar de C a B o A, verificar que el puerto quedo libre antes de arrancar el servicio en
el host:

```powershell
curl -s -o /dev/null -w "%{http_code}" http://localhost:8083/actuator/health
```

Un `000` significa que nadie responde, o sea que el puerto esta disponible.

---

## 7. Verificacion

| URL | Resultado esperado |
|-----|--------------------|
| http://localhost:8761 | Dashboard de Eureka con `API-GATEWAY`, `MS-ADMINISTRACION`, `MS-PROYECTOS` y `MS-SEGUIMIENTO` registrados |
| http://localhost:8080/actuator/health | `{"status":"UP"}` |
| http://localhost:8081/actuator/health · :8082 · :8083 | `{"status":"UP"}` |
| http://localhost:8081/swagger-ui.html · :8082 · :8083 | Swagger UI de los 3 microservicios de dominio |
| http://localhost:4200 | Frontend Angular |

Comprobar los 5 servicios de una sola vez:

```powershell
8761,8080,8081,8082,8083 | ForEach-Object { "$_ -> " + (curl.exe -s -o NUL -w "%{http_code}" "http://localhost:$_/actuator/health") }
```

En el **Modo B**, en el dashboard de Eureka la instancia de `MS-SEGUIMIENTO` debe mostrar
`host.docker.internal:8083`. Si muestra una IP `192.168.x.x`, las VM options no se aplicaron.

### Migraciones aplicadas

```powershell
docker exec spsrt-postgres psql -U spsrt_administracion_user -d spsrt_administracion -c "SELECT version, description, success FROM flyway_schema_history ORDER BY installed_rank;"
```

### Swagger

Lo exponen **solo los 3 microservicios de dominio**. `eureka-server` y `api-gateway` no
tienen Swagger: ninguno expone API de negocio. Eureka tiene su propio dashboard en
http://localhost:8761 y el gateway solo enruta, con sus rutas declaradas en el
`application.yml`.

| Servicio | Swagger UI | OpenAPI |
|----------|-----------|---------|
| ms-administracion | http://localhost:8081/swagger-ui.html | `:8081/v3/api-docs` |
| ms-proyectos | http://localhost:8082/swagger-ui.html | `:8082/v3/api-docs` |
| ms-seguimiento | http://localhost:8083/swagger-ui.html | `:8083/v3/api-docs` |

**Como autenticarse en Swagger.** La UI de cada microservicio apunta a su propio puerto, o
sea que las llamadas van directo al servicio sin pasar por el gateway. Los endpoints
protegidos igual piden el JWT, porque cada microservicio lo valida por su cuenta, pero el
token hay que conseguirlo aparte:

1. Hacer login contra el gateway (ver la seccion siguiente) y copiar el JWT de la respuesta.
2. En Swagger, boton **Authorize**, pegar el token y confirmar.
3. A partir de ahi la UI manda el header `Authorization: Bearer <token>` en cada request.

Para probar el circuito completo pasando por el gateway esta la coleccion **Bruno** en
`orquestacion/Test/`, que encadena el login y reutiliza el JWT en los ~76 requests.

En el **Modo B**, `ms-seguimiento` corre en el host: su Swagger sigue en
http://localhost:8083/swagger-ui.html, servido por la instancia de IntelliJ en vez del
contenedor.

### Usuarios de desarrollo

El acceso entra por el gateway:

```
POST http://localhost:8080/api/auth/login
Content-Type: application/json

{ "email": "admin@srp.local", "contrasenia": "Admin123" }
```

Devuelve un JWT que se envia como `Authorization: Bearer <token>` en el resto de endpoints.

Usuarios cargados por las migraciones de `ms-administracion`:

| Email | Contrasena | Rol |
|-------|-----------|-----|
| `admin@srp.local` | `Admin123` | ADMIN |
| `pedro.soria@institucion.gob.pe` | `Spsrt.2026` | ADMIN |
| `marcos.pacheco@institucion.gob.pe` | `Spsrt.2026` | GESTOR_PROYECTO |
| `edwin.pacheco@institucion.gob.pe` | `Spsrt.2026` | RECURSO_TECNICO |
| `juan.perez@institucion.gob.pe` | `Spsrt.2026` | JEFE_AREA |

Los cuatro roles del sistema tienen usuario, para poder probar cada vista.

---

## 8. Problemas frecuentes

### pnpm: command not found

fnm no esta inicializado en ese shell. En PowerShell la linea va en el perfil (`$PROFILE`);
en Git Bash, en `~/.bashrc`.

### ERR_VM_DYNAMIC_IMPORT_CALLBACK_MISSING al correr pnpm

El corepack empaquetado con Node 20 no puede ejecutar pnpm 11. Se resuelve usando
**Node 24.18.0**, que es lo que fija el `.nvmrc`. Verificar con `node -v`.

### El build falla con "path not found" en el contexto

Los repos no estan en `../Backend/<servicio>`. Definir `BACKEND_ROOT` en el `.env` con la
ruta correcta y comprobar con `docker compose config`.

### El gateway devuelve 503 para las rutas de seguimiento (Modo B)

Falta el registro con `host.docker.internal`. Revisar las VM options y confirmar la direccion
de la instancia en el dashboard de Eureka.

### Todos los endpoints responden 401 (Modo B)

El `JWT_SECRET` de la Run Configuration no coincide con el del `.env` de orquestacion.

### El puerto 8083 esta ocupado (Modos A y B)

Quedo corriendo el contenedor del stack completo:

```powershell
docker compose stop ms-seguimiento
```

### Errores de conexion a Eureka en los logs

Si un microservicio arranca antes que Eureka, loguea errores de registro. No bloquean el
arranque: el cliente reintenta en background y termina registrandose.

### IntelliJ marca "cannot find symbol" en getters o mappers

Falta habilitar annotation processing. El proyecto usa Lombok y MapStruct; ver la
seccion 4.2.

### Migraciones Flyway nuevas

Las migraciones viven en `src/main/resources/db/migration/V*.sql` de cada microservicio y son
la fuente unica. Flyway las aplica al arrancar el servicio.

Como el proyecto esta en desarrollo y las bases son desechables, una migracion ya aplicada se
puede corregir en sitio en vez de agregar una nueva. En ese caso **hay que avisar al equipo**:
quien ya la tenga aplicada necesita borrar su volumen, o su servicio no arranca y falla con
`Validate failed: Migration checksum mismatch`.

```powershell
docker compose down -v
docker compose up -d --build
```

---

## 9. Apagar el entorno

```powershell
cd "C:\Users\PESSL\Documents\WS-UNIR\TFM\Development\orquestacion"

# detener los contenedores conservando los datos
docker compose stop

# detener y eliminar contenedores (los datos sobreviven en el volumen)
docker compose down

# eliminar tambien los datos de PostgreSQL
docker compose down -v
```

`docker compose down -v` borra el volumen `postgres-data`: al volver a levantar, las 3 bases
se recrean desde cero y Flyway reaplica todas las migraciones. Util para partir de un estado
limpio.

Los servicios que corren en el host se detienen con `Ctrl+C` en su terminal o desde el panel
de ejecucion de IntelliJ.
