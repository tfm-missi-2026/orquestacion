-- =====================================================================
-- Sistema      : SPSRT - Sistema de Planificacion y Seguimiento de Recursos Tecnicos
-- Modulo       : MS Administracion
-- Objetivo     : Esquema inicial del MS Administracion. Crea las 5 tablas
--                (msa_rol, msa_usuario, msa_catalogo, msa_modulo,
--                msa_rol_modulo) con sus indices, restricciones y
--                comentarios de tabla y columnas.
-- Desarrollado : Equipo SPSRT - UNIR
-- Fecha        : 2026-05-27
-- =====================================================================

-- ---------------------------------------------------------------------
-- Extension requerida para gen_random_uuid() (PK uuid de todas las tablas)
-- ---------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------------------------------------------------------------------
-- Tabla msa_rol
-- ---------------------------------------------------------------------
CREATE TABLE msa_rol (
    id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo               VARCHAR(50)  NOT NULL UNIQUE,
    nombre               VARCHAR(100) NOT NULL,
    descripcion          VARCHAR(500),
    estado               SMALLINT     NOT NULL DEFAULT 1 CHECK (estado IN (0, 1)),
    fecha_creacion       TIMESTAMP    NOT NULL,
    usuario_creacion     UUID         NOT NULL,
    fecha_modificacion   TIMESTAMP,
    usuario_modificacion UUID,
    fecha_eliminacion    TIMESTAMP,
    usuario_eliminacion  UUID,
    motivo_eliminacion   VARCHAR(500)
);

CREATE UNIQUE INDEX idx_msa_rol_codigo ON msa_rol(codigo);

COMMENT ON TABLE  msa_rol IS 'Catalogo maestro de roles del sistema';
COMMENT ON COLUMN msa_rol.id IS 'Identificador unico del rol';
COMMENT ON COLUMN msa_rol.codigo IS 'Codigo unico del rol (ADMIN, JEFE_AREA, GESTOR_PROYECTO, RECURSO_TECNICO)';
COMMENT ON COLUMN msa_rol.nombre IS 'Nombre legible del rol';
COMMENT ON COLUMN msa_rol.descripcion IS 'Descripcion extendida del rol';
COMMENT ON COLUMN msa_rol.estado IS 'Estado del registro (0=inactivo, 1=activo)';
COMMENT ON COLUMN msa_rol.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN msa_rol.usuario_creacion IS 'UUID del usuario que creo el registro';
COMMENT ON COLUMN msa_rol.fecha_modificacion IS 'Fecha y hora de ultima modificacion';
COMMENT ON COLUMN msa_rol.usuario_modificacion IS 'UUID del usuario que modifico el registro';
COMMENT ON COLUMN msa_rol.fecha_eliminacion IS 'Fecha y hora de eliminacion logica (NULL si activo)';
COMMENT ON COLUMN msa_rol.usuario_eliminacion IS 'UUID del usuario que elimino el registro (NULL si activo)';
COMMENT ON COLUMN msa_rol.motivo_eliminacion IS 'Motivo de la eliminacion logica (obligatorio si fecha_eliminacion IS NOT NULL)';

-- ---------------------------------------------------------------------
-- Tabla msa_usuario
-- ---------------------------------------------------------------------
CREATE TABLE msa_usuario (
    id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    email                VARCHAR(150) NOT NULL UNIQUE,
    contrasenia          VARCHAR(100) NOT NULL,
    nombres              VARCHAR(100) NOT NULL,
    apellido_paterno     VARCHAR(100) NOT NULL,
    apellido_materno     VARCHAR(100) NOT NULL,
    rol_id               UUID         NOT NULL REFERENCES msa_rol(id),
    estado               SMALLINT     NOT NULL DEFAULT 1 CHECK (estado IN (0, 1)),
    fecha_creacion       TIMESTAMP    NOT NULL,
    usuario_creacion     UUID         NOT NULL,
    fecha_modificacion   TIMESTAMP,
    usuario_modificacion UUID,
    fecha_eliminacion    TIMESTAMP,
    usuario_eliminacion  UUID,
    motivo_eliminacion   VARCHAR(500)
);

CREATE UNIQUE INDEX idx_msa_usuario_email ON msa_usuario(email);
CREATE INDEX idx_msa_usuario_rol ON msa_usuario(rol_id);

COMMENT ON TABLE  msa_usuario IS 'Usuarios del sistema con credenciales y datos basicos';
COMMENT ON COLUMN msa_usuario.id IS 'Identificador unico del usuario';
COMMENT ON COLUMN msa_usuario.email IS 'Email unico del usuario (usado como login)';
COMMENT ON COLUMN msa_usuario.contrasenia IS 'Hash BCrypt de la contrasena';
COMMENT ON COLUMN msa_usuario.nombres IS 'Nombres del usuario';
COMMENT ON COLUMN msa_usuario.apellido_paterno IS 'Apellido paterno del usuario';
COMMENT ON COLUMN msa_usuario.apellido_materno IS 'Apellido materno del usuario';
COMMENT ON COLUMN msa_usuario.rol_id IS 'FK al rol asignado en msa_rol';
COMMENT ON COLUMN msa_usuario.estado IS 'Estado del registro (0=inactivo, 1=activo)';
COMMENT ON COLUMN msa_usuario.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN msa_usuario.usuario_creacion IS 'UUID del usuario que creo el registro';
COMMENT ON COLUMN msa_usuario.fecha_modificacion IS 'Fecha y hora de ultima modificacion';
COMMENT ON COLUMN msa_usuario.usuario_modificacion IS 'UUID del usuario que modifico el registro';
COMMENT ON COLUMN msa_usuario.fecha_eliminacion IS 'Fecha y hora de eliminacion logica (NULL si activo)';
COMMENT ON COLUMN msa_usuario.usuario_eliminacion IS 'UUID del usuario que elimino el registro (NULL si activo)';
COMMENT ON COLUMN msa_usuario.motivo_eliminacion IS 'Motivo de la eliminacion logica (obligatorio si fecha_eliminacion IS NOT NULL)';

-- ---------------------------------------------------------------------
-- Tabla msa_catalogo
-- ---------------------------------------------------------------------
CREATE TABLE msa_catalogo (
    id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    grupo                VARCHAR(50)  NOT NULL,
    id_opcion            SMALLINT     NOT NULL,
    opcion               VARCHAR(150) NOT NULL,
    estado               SMALLINT     NOT NULL DEFAULT 1 CHECK (estado IN (0, 1)),
    fecha_creacion       TIMESTAMP    NOT NULL,
    usuario_creacion     UUID         NOT NULL,
    fecha_modificacion   TIMESTAMP,
    usuario_modificacion UUID,
    fecha_eliminacion    TIMESTAMP,
    usuario_eliminacion  UUID,
    motivo_eliminacion   VARCHAR(500)
);

CREATE UNIQUE INDEX uk_msa_catalogo_grupo_opcion ON msa_catalogo(grupo, id_opcion);

COMMENT ON TABLE  msa_catalogo IS 'Catalogo generico unificado del sistema (sirve a todos los MS via cross-BD)';
COMMENT ON COLUMN msa_catalogo.id IS 'Identificador unico del item de catalogo';
COMMENT ON COLUMN msa_catalogo.grupo IS 'Categoria del catalogo (TIPO_SUBPROYECTO, PRIORIDAD, SITUACION, TIPO_VARIACION, SITUACION_VARIACION, TIPO_ACTIVIDAD, MODALIDAD)';
COMMENT ON COLUMN msa_catalogo.id_opcion IS 'Codigo numerico de la opcion dentro del grupo';
COMMENT ON COLUMN msa_catalogo.opcion IS 'Texto visible de la opcion';
COMMENT ON COLUMN msa_catalogo.estado IS 'Estado del registro (0=inactivo, 1=activo)';
COMMENT ON COLUMN msa_catalogo.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN msa_catalogo.usuario_creacion IS 'UUID del usuario que creo el registro';
COMMENT ON COLUMN msa_catalogo.fecha_modificacion IS 'Fecha y hora de ultima modificacion';
COMMENT ON COLUMN msa_catalogo.usuario_modificacion IS 'UUID del usuario que modifico el registro';
COMMENT ON COLUMN msa_catalogo.fecha_eliminacion IS 'Fecha y hora de eliminacion logica (NULL si activo)';
COMMENT ON COLUMN msa_catalogo.usuario_eliminacion IS 'UUID del usuario que elimino el registro (NULL si activo)';
COMMENT ON COLUMN msa_catalogo.motivo_eliminacion IS 'Motivo de la eliminacion logica (obligatorio si fecha_eliminacion IS NOT NULL)';

-- ---------------------------------------------------------------------
-- Tabla msa_modulo
-- ---------------------------------------------------------------------
CREATE TABLE msa_modulo (
    id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo               VARCHAR(50)  NOT NULL UNIQUE,
    nombre               VARCHAR(100) NOT NULL,
    ruta                 VARCHAR(150) NOT NULL,
    icono                VARCHAR(50),
    orden                SMALLINT     NOT NULL,
    modulo_padre_id      UUID         REFERENCES msa_modulo(id),
    descripcion          TEXT,
    estado               SMALLINT     NOT NULL DEFAULT 1 CHECK (estado IN (0, 1)),
    fecha_creacion       TIMESTAMP    NOT NULL,
    usuario_creacion     UUID         NOT NULL,
    fecha_modificacion   TIMESTAMP,
    usuario_modificacion UUID,
    fecha_eliminacion    TIMESTAMP,
    usuario_eliminacion  UUID,
    motivo_eliminacion   VARCHAR(500)
);

CREATE UNIQUE INDEX idx_msa_modulo_codigo ON msa_modulo(codigo);
CREATE INDEX idx_msa_modulo_padre ON msa_modulo(modulo_padre_id);

COMMENT ON TABLE  msa_modulo IS 'Modulos del sidebar del frontend (con jerarquia opcional para submenus)';
COMMENT ON COLUMN msa_modulo.id IS 'Identificador unico del modulo';
COMMENT ON COLUMN msa_modulo.codigo IS 'Codigo unico del modulo (PROYECTOS, TAREAS, ASIGNACIONES, VARIACIONES, USUARIOS, etc.)';
COMMENT ON COLUMN msa_modulo.nombre IS 'Nombre visible en el sidebar';
COMMENT ON COLUMN msa_modulo.ruta IS 'Ruta del frontend (ej. /proyectos)';
COMMENT ON COLUMN msa_modulo.icono IS 'Nombre del icono del sidebar (ej. heroicon name)';
COMMENT ON COLUMN msa_modulo.orden IS 'Orden de aparicion en el sidebar';
COMMENT ON COLUMN msa_modulo.modulo_padre_id IS 'FK al modulo padre (NULL si es de primer nivel; permite submenus)';
COMMENT ON COLUMN msa_modulo.descripcion IS 'Descripcion del modulo';
COMMENT ON COLUMN msa_modulo.estado IS 'Estado del registro (0=inactivo, 1=activo)';
COMMENT ON COLUMN msa_modulo.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN msa_modulo.usuario_creacion IS 'UUID del usuario que creo el registro';
COMMENT ON COLUMN msa_modulo.fecha_modificacion IS 'Fecha y hora de ultima modificacion';
COMMENT ON COLUMN msa_modulo.usuario_modificacion IS 'UUID del usuario que modifico el registro';
COMMENT ON COLUMN msa_modulo.fecha_eliminacion IS 'Fecha y hora de eliminacion logica (NULL si activo)';
COMMENT ON COLUMN msa_modulo.usuario_eliminacion IS 'UUID del usuario que elimino el registro (NULL si activo)';
COMMENT ON COLUMN msa_modulo.motivo_eliminacion IS 'Motivo de la eliminacion logica (obligatorio si fecha_eliminacion IS NOT NULL)';

-- ---------------------------------------------------------------------
-- Tabla msa_rol_modulo
-- ---------------------------------------------------------------------
CREATE TABLE msa_rol_modulo (
    id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    rol_id               UUID         NOT NULL REFERENCES msa_rol(id),
    modulo_id            UUID         NOT NULL REFERENCES msa_modulo(id),
    estado               SMALLINT     NOT NULL DEFAULT 1 CHECK (estado IN (0, 1)),
    fecha_creacion       TIMESTAMP    NOT NULL,
    usuario_creacion     UUID         NOT NULL,
    fecha_modificacion   TIMESTAMP,
    usuario_modificacion UUID,
    fecha_eliminacion    TIMESTAMP,
    usuario_eliminacion  UUID,
    motivo_eliminacion   VARCHAR(500)
);

CREATE UNIQUE INDEX uk_msa_rol_modulo ON msa_rol_modulo(rol_id, modulo_id);
CREATE INDEX idx_msa_rol_modulo_rol ON msa_rol_modulo(rol_id);
CREATE INDEX idx_msa_rol_modulo_modulo ON msa_rol_modulo(modulo_id);

COMMENT ON TABLE  msa_rol_modulo IS 'Asignacion M:N de modulos accesibles por rol (RBAC del sidebar)';
COMMENT ON COLUMN msa_rol_modulo.id IS 'Identificador unico del vinculo rol-modulo';
COMMENT ON COLUMN msa_rol_modulo.rol_id IS 'FK al rol';
COMMENT ON COLUMN msa_rol_modulo.modulo_id IS 'FK al modulo accesible';
COMMENT ON COLUMN msa_rol_modulo.estado IS 'Estado del registro (0=inactivo, 1=activo)';
COMMENT ON COLUMN msa_rol_modulo.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN msa_rol_modulo.usuario_creacion IS 'UUID del usuario que creo el registro';
COMMENT ON COLUMN msa_rol_modulo.fecha_modificacion IS 'Fecha y hora de ultima modificacion';
COMMENT ON COLUMN msa_rol_modulo.usuario_modificacion IS 'UUID del usuario que modifico el registro';
COMMENT ON COLUMN msa_rol_modulo.fecha_eliminacion IS 'Fecha y hora de eliminacion logica (NULL si activo)';
COMMENT ON COLUMN msa_rol_modulo.usuario_eliminacion IS 'UUID del usuario que elimino el registro (NULL si activo)';
COMMENT ON COLUMN msa_rol_modulo.motivo_eliminacion IS 'Motivo de la eliminacion logica (obligatorio si fecha_eliminacion IS NOT NULL)';
