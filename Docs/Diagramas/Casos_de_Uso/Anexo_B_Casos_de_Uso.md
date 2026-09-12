# Anexo B. Casos de uso — texto para pegar en Word

Cierra la referencia colgada del apartado 4.1.4 («El resto de los casos de uso se especifica
con el mismo formato en el Anexo correspondiente»).

**Seis fichas**: CU-01, CU-02, CU-03, CU-05, CU-06 y CU-07. CU-04 y CU-08 ya están en el
cuerpo como Tablas 11 y 12, y no se repiten aquí.

Cada ficha usa los ocho campos del formato vigente y está verificada contra el código de
`Development/backend/`, no solo contra los diagramas de actividad.

## Convención de numeración

El anexo **reinicia su propia numeración**: Tabla 1 a Tabla 6. Es lo que hace el TFM de
referencia de la misma titulación (Teruel, MISSI), y evita tocar las figuras y tablas del
cuerpo. El pie mantiene el estilo del documento:

- `Tabla N. Especificación del caso de uso CU-XX.` seguido de `Fuente: Elaboración propia.`

Los **diagramas de actividad no van acá**: los seis ya están en el **Anexo C**. Este anexo lleva
solo las seis fichas.

## Texto de apertura del anexo

> Este anexo recoge la especificación textual de los seis casos de uso que no se detallan en
> el cuerpo del trabajo. Las especificaciones de CU-04 y CU-08 figuran en el apartado 4.1.4, en
> las Tablas 11 y 12, y sus diagramas de actividad en las Figuras 8 y 9. Todas siguen el mismo
> formato de ocho campos y describen el comportamiento efectivamente implementado en el
> prototipo. Los diagramas de actividad correspondientes se presentan en el Anexo C.

---

## Tabla 1. Especificación del caso de uso CU-01

| Campo | Contenido |
|---|---|
| Identificador | CU-01 |
| Nombre | Autenticar usuario |
| Actor primario | A1 - Jefe del área, A2 - Gestor de proyecto, A3 - Recurso técnico, A4 - Administrador del sistema |
| Actores secundarios | Ninguno |
| Precondición | El usuario está dado de alta en el catálogo de usuarios, con un rol asignado y estado activo. |
| Flujo principal | 1. El usuario accede a la pantalla de inicio de sesión.<br><br>2. El sistema solicita el correo electrónico y la contraseña.<br><br>3. El usuario introduce sus credenciales y confirma.<br><br>4. El sistema verifica que exista un usuario activo con ese correo y que la contraseña coincida con el resumen criptográfico almacenado.<br><br>5. El sistema genera un token de sesión firmado que incorpora el identificador del usuario, su rol y la marca de expiración.<br><br>6. El sistema devuelve el token, su vigencia y los datos del usuario autenticado.<br><br>7. El cliente conserva el token y lo adjunta en la cabecera de autorización de cada petición posterior.<br><br>8. El usuario accede al panel y al menú que corresponden a su rol. |
| Flujos alternativos | 4a. Si no existe un usuario activo con ese correo, el sistema responde con un error de credenciales inválidas, sin revelar si la cuenta existe o está deshabilitada.<br><br>4b. Si la contraseña no coincide, el sistema devuelve el mismo error de credenciales inválidas.<br><br>7a. Si el token ha expirado, el sistema rechaza la petición, el cliente invalida la sesión local y redirige a la pantalla de inicio de sesión. |
| Postcondición | La sesión queda activa mientras dure la vigencia del token. El servidor no conserva estado de sesión, de modo que la autorización de cada petición se resuelve a partir del propio token. |

*Fuente: Elaboración propia.*

---

## Tabla 2. Especificación del caso de uso CU-02

| Campo | Contenido |
|---|---|
| Identificador | CU-02 |
| Nombre | Gestionar usuarios y roles |
| Actor primario | A4 - Administrador del sistema |
| Actores secundarios | Ninguno |
| Precondición | El actor está autenticado con rol de administrador y existen roles definidos en el sistema. |
| Flujo principal | 1. El administrador accede al módulo de administración y elige la operación: alta, modificación, baja, restablecimiento de contraseña o cambio de rol.<br><br>2. El sistema muestra el formulario correspondiente con la relación de roles disponibles.<br><br>3. El administrador completa los datos y confirma.<br><br>4. El sistema valida que el correo no corresponda a otro usuario activo y que el rol indicado exista.<br><br>5. El sistema cifra la contraseña y persiste el usuario junto con sus datos de auditoría.<br><br>6. El sistema confirma la operación y actualiza el listado. |
| Flujos alternativos | 4a. Si el correo ya corresponde a un usuario activo, el sistema informa el conflicto y no persiste el alta.<br><br>4b. Si el rol indicado no existe, el sistema notifica el error y cancela la operación.<br><br>3a. En la baja, el sistema exige un motivo de eliminación antes de proceder.<br><br>3b. Al configurar los módulos de un rol, el sistema impide retirar el que está definido como página de inicio, y exige que todo rol conserve una. |
| Postcondición | La operación queda persistida con el autor y la marca temporal. La baja es lógica: el registro conserva su historial y el correo queda disponible para un alta posterior. |

*Fuente: Elaboración propia.*

---

## Tabla 3. Especificación del caso de uso CU-03

| Campo | Contenido |
|---|---|
| Identificador | CU-03 |
| Nombre | Crear proyecto |
| Actor primario | A2 - Gestor de proyecto |
| Actores secundarios | A4 - Administrador del sistema |
| Precondición | El actor está autenticado con permisos sobre el módulo de proyectos y el gestor responsable está dado de alta en el catálogo de usuarios. |
| Flujo principal | 1. El gestor accede al módulo de proyectos y solicita crear uno nuevo.<br><br>2. El sistema muestra el formulario con el nombre corto, el nombre, la descripción y el gestor responsable.<br><br>3. El gestor completa los datos y confirma.<br><br>4. El sistema valida los campos obligatorios: el nombre y el gestor responsable.<br><br>5. El sistema comprueba que el nombre corto no corresponda a otro proyecto activo.<br><br>6. El sistema persiste el proyecto con sus datos de auditoría y lo incorpora al listado. |
| Flujos alternativos | 4a. Si falta el nombre o el gestor responsable, el sistema no persiste el proyecto e informa el campo requerido.<br><br>5a. Si el nombre corto ya está en uso por un proyecto activo, el sistema informa el conflicto y cancela la operación. |
| Postcondición | El proyecto queda registrado y disponible para definir sobre él subproyectos y tareas. El proyecto actúa como agrupador: las fechas estimadas se establecen en las tareas y la prioridad en el subproyecto. |

*Fuente: Elaboración propia.*

---

## Tabla 4. Especificación del caso de uso CU-05

| Campo | Contenido |
|---|---|
| Identificador | CU-05 |
| Nombre | Consultar carga del equipo |
| Actor primario | A1 - Jefe del área de desarrollo |
| Actores secundarios | A2 - Gestor de proyecto |
| Precondición | El actor está autenticado con rol de jefe del área, gestor de proyecto o administrador, y existen asignaciones o registros de dedicación dentro del rango que se consulta. |
| Flujo principal | 1. El jefe del área accede al módulo de carga del equipo.<br><br>2. El sistema solicita el rango de fechas y, de forma opcional, un filtro por tareas.<br><br>3. El actor indica el rango y aplica el filtro si lo requiere.<br><br>4. El sistema suma, por recurso, las horas planificadas en sus asignaciones y las horas efectivamente registradas en la bitácora dentro del rango.<br><br>5. El sistema calcula el porcentaje de utilización como las horas registradas sobre las planificadas, y marca en sobrecarga a los recursos cuyas horas registradas superan las planificadas.<br><br>6. El sistema devuelve la carga de cada recurso con su número de tareas activas, y el actor identifica los recursos en sobrecarga. |
| Flujos alternativos | 3a. Si la fecha inicial es posterior a la final, el sistema rechaza la consulta e informa el error.<br><br>5a. Si el recurso no tiene horas planificadas en el rango, el sistema reporta una utilización del cero por ciento y no lo marca en sobrecarga, aunque tenga horas registradas.<br><br>1a. Un recurso técnico solo puede consultar su propia carga; el sistema deniega el acceso a la de otro recurso. |
| Postcondición | La vista se calcula en el momento de la consulta a partir de los datos vigentes y no modifica ningún registro. |

*Fuente: Elaboración propia.*

---

## Tabla 5. Especificación del caso de uso CU-06

| Campo | Contenido |
|---|---|
| Identificador | CU-06 |
| Nombre | Registrar dedicación real |
| Actor primario | A3 - Recurso técnico |
| Actores secundarios | Ninguno |
| Precondición | El actor está autenticado y existe una asignación de tarea o una actividad sobre la cual imputar el tiempo. |
| Flujo principal | 1. El recurso técnico accede a su bitácora y consulta los registros del periodo.<br><br>2. El sistema muestra las entradas ya registradas en el rango.<br><br>3. El recurso elige a qué imputar el tiempo: una asignación de tarea o una actividad.<br><br>4. El recurso indica la fecha, la hora de inicio, la hora de fin y una descripción, y confirma.<br><br>5. El sistema resuelve el usuario a partir del token de sesión y valida que se haya indicado exactamente uno entre asignación y actividad, y que la hora de fin sea posterior a la de inicio.<br><br>6. El sistema persiste el registro con sus datos de auditoría y confirma la operación. |
| Flujos alternativos | 5a. Si se indican a la vez una asignación y una actividad, o no se indica ninguna de las dos, el sistema informa el conflicto y no persiste el registro.<br><br>5b. Si la hora de fin no es posterior a la de inicio, el sistema informa el error y no persiste el registro.<br><br>5c. Si falta la fecha o alguna de las horas, el sistema no persiste el registro e informa el campo requerido. |
| Postcondición | La entrada queda registrada en la bitácora del recurso y pasa a alimentar el cálculo de la carga del equipo (CU-05) y del avance del proyecto (CU-07). |

*Fuente: Elaboración propia.*

---

## Tabla 6. Especificación del caso de uso CU-07

| Campo | Contenido |
|---|---|
| Identificador | CU-07 |
| Nombre | Consultar avance del proyecto |
| Actor primario | A2 - Gestor de proyecto |
| Actores secundarios | A1 - Jefe del área de desarrollo |
| Precondición | El actor está autenticado con permisos sobre el proyecto y existe una línea base congelada sobre la que contrastar la ejecución. |
| Flujo principal | 1. El gestor accede al proyecto y selecciona la consulta de avance.<br><br>2. El sistema recupera la línea base vigente del proyecto.<br><br>3. El sistema recorre las tareas incluidas en la línea base y suma, por tarea, las horas estimadas y las horas registradas en la bitácora.<br><br>4. El sistema calcula el avance de cada tarea y el del conjunto del proyecto como las horas registradas sobre las estimadas.<br><br>5. El gestor visualiza la comparación entre lo planificado y lo ejecutado, e identifica las tareas desviadas. |
| Flujos alternativos | 2a. Si el proyecto no tiene ninguna línea base congelada, el sistema informa que no existe línea base y no devuelve avance.<br><br>3a. Si una tarea de la línea base no tiene horas registradas, su avance se reporta como cero y la tarea se conserva en el detalle. |
| Postcondición | La vista se calcula en el momento de la consulta contra la línea base congelada y no modifica ningún registro. |

*Fuente: Elaboración propia.*

---

## Ajuste necesario en el cuerpo

El apartado 4.1.4 dice hoy:

> El resto de los casos de uso se especifica con el mismo formato en el **Anexo correspondiente**.

Sustituir por:

> El resto de los casos de uso se especifica con el mismo formato en el **Anexo B**.

*Fuente. Elaboración propia.*
