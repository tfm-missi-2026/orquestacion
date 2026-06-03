-- =====================================================================
-- Sistema      : SPSRT - Sistema de Planificacion y Seguimiento de Recursos Tecnicos
-- Modulo       : MS Proyectos
-- Objetivo     : Esquema inicial del MS Proyectos. Crea las 3 tablas
--                (msp_proyecto, msp_subproyecto, msp_tarea) con su
--                jerarquia (sistema -> subproyecto -> tarea), indices,
--                restricciones y comentarios.
-- Desarrollado : Equipo SPSRT - UNIR
-- Fecha        : 2026-05-27
-- =====================================================================

-- ---------------------------------------------------------------------
-- Extension requerida para gen_random_uuid() (PK uuid de todas las tablas)
-- ---------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------------------------------------------------------------------
-- Tabla msp_proyecto (sistemas)
-- ---------------------------------------------------------------------
CREATE TABLE msp_proyecto (
    id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre_corto         VARCHAR(50)  UNIQUE,
    nombre               VARCHAR(200) NOT NULL,
    descripcion          TEXT,
    gestor_id            UUID         NOT NULL,
    estado               SMALLINT     NOT NULL DEFAULT 1 CHECK (estado IN (0, 1)),
    fecha_creacion       TIMESTAMP    NOT NULL,
    usuario_creacion     UUID         NOT NULL,
    fecha_modificacion   TIMESTAMP,
    usuario_modificacion UUID,
    fecha_eliminacion    TIMESTAMP,
    usuario_eliminacion  UUID,
    motivo_eliminacion   VARCHAR(500)
);

CREATE UNIQUE INDEX idx_msp_proyecto_nombre_corto ON msp_proyecto(nombre_corto);
CREATE INDEX idx_msp_proyecto_gestor ON msp_proyecto(gestor_id);

COMMENT ON TABLE  msp_proyecto IS 'Catalogo de sistemas (existentes y por desarrollar) gestionados por el area';
COMMENT ON COLUMN msp_proyecto.id IS 'Identificador unico del sistema/proyecto';
COMMENT ON COLUMN msp_proyecto.nombre_corto IS 'Codigo legible unico del sistema (ej. SIGTRAMITES, SIRECAUDA)';
COMMENT ON COLUMN msp_proyecto.nombre IS 'Nombre del sistema';
COMMENT ON COLUMN msp_proyecto.descripcion IS 'Descripcion del sistema';
COMMENT ON COLUMN msp_proyecto.gestor_id IS 'UUID del gestor responsable del sistema (cross-BD a msa_usuario, sin FK)';
COMMENT ON COLUMN msp_proyecto.estado IS 'Estado del registro (0=inactivo, 1=activo)';
COMMENT ON COLUMN msp_proyecto.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN msp_proyecto.usuario_creacion IS 'UUID del usuario que creo el registro';
COMMENT ON COLUMN msp_proyecto.fecha_modificacion IS 'Fecha y hora de ultima modificacion';
COMMENT ON COLUMN msp_proyecto.usuario_modificacion IS 'UUID del usuario que modifico el registro';
COMMENT ON COLUMN msp_proyecto.fecha_eliminacion IS 'Fecha y hora de eliminacion logica (NULL si activo)';
COMMENT ON COLUMN msp_proyecto.usuario_eliminacion IS 'UUID del usuario que elimino el registro (NULL si activo)';
COMMENT ON COLUMN msp_proyecto.motivo_eliminacion IS 'Motivo de la eliminacion logica (obligatorio si fecha_eliminacion IS NOT NULL)';

-- ---------------------------------------------------------------------
-- Tabla msp_subproyecto (incidencia / requerimiento / desarrollo modular)
-- ---------------------------------------------------------------------
CREATE TABLE msp_subproyecto (
    id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    proyecto_id          UUID         NOT NULL REFERENCES msp_proyecto(id),
    tipo_subproyecto_id  UUID         NOT NULL,
    codigo_ticket        VARCHAR(50),
    prioridad_id         UUID         NOT NULL,
    descripcion          TEXT         NOT NULL,
    solicitante_id       UUID         NOT NULL,
    fecha_solicitud      DATE         NOT NULL,
    situacion_id         UUID         NOT NULL,
    justificacion_rechazo VARCHAR(500),
    estado               SMALLINT     NOT NULL DEFAULT 1 CHECK (estado IN (0, 1)),
    fecha_creacion       TIMESTAMP    NOT NULL,
    usuario_creacion     UUID         NOT NULL,
    fecha_modificacion   TIMESTAMP,
    usuario_modificacion UUID,
    fecha_eliminacion    TIMESTAMP,
    usuario_eliminacion  UUID,
    motivo_eliminacion   VARCHAR(500)
);

CREATE INDEX idx_msp_subproy_proyecto ON msp_subproyecto(proyecto_id);
CREATE INDEX idx_msp_subproy_tipo ON msp_subproyecto(tipo_subproyecto_id);
CREATE INDEX idx_msp_subproy_situacion ON msp_subproyecto(situacion_id);
CREATE INDEX idx_msp_subproy_solicitante ON msp_subproyecto(solicitante_id);

COMMENT ON TABLE  msp_subproyecto IS 'Subproyecto: unidad de trabajo (incidencia, requerimiento o desarrollo modular) solicitada sobre un sistema. La situacion se deriva del estado de sus tareas (capa de aplicacion)';
COMMENT ON COLUMN msp_subproyecto.id IS 'Identificador unico del subproyecto';
COMMENT ON COLUMN msp_subproyecto.proyecto_id IS 'FK al sistema al que pertenece el subproyecto';
COMMENT ON COLUMN msp_subproyecto.tipo_subproyecto_id IS 'FK al tipo en msa_catalogo grupo=TIPO_SUBPROYECTO (Incidencia, Requerimiento, Desarrollo modular) (cross-BD)';
COMMENT ON COLUMN msp_subproyecto.codigo_ticket IS 'Codigo de ticket externo (Jira, ServiceDesk, etc.) cuando aplica';
COMMENT ON COLUMN msp_subproyecto.prioridad_id IS 'FK a la prioridad en msa_catalogo grupo=PRIORIDAD (cross-BD)';
COMMENT ON COLUMN msp_subproyecto.descripcion IS 'Detalle del subproyecto: alcance del requerimiento, descripcion del incidente o del desarrollo modular';
COMMENT ON COLUMN msp_subproyecto.solicitante_id IS 'UUID del usuario que solicito (cross-BD a msa_usuario)';
COMMENT ON COLUMN msp_subproyecto.fecha_solicitud IS 'Fecha en que se registro la solicitud';
COMMENT ON COLUMN msp_subproyecto.situacion_id IS 'FK a la situacion en msa_catalogo grupo=SITUACION (Pendiente, En atencion, Culminado, Rechazado) (cross-BD)';
COMMENT ON COLUMN msp_subproyecto.justificacion_rechazo IS 'Motivo del rechazo (obligatorio si situacion=Rechazado)';
COMMENT ON COLUMN msp_subproyecto.estado IS 'Estado del registro (0=inactivo, 1=activo)';
COMMENT ON COLUMN msp_subproyecto.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN msp_subproyecto.usuario_creacion IS 'UUID del usuario que creo el registro';
COMMENT ON COLUMN msp_subproyecto.fecha_modificacion IS 'Fecha y hora de ultima modificacion';
COMMENT ON COLUMN msp_subproyecto.usuario_modificacion IS 'UUID del usuario que modifico el registro';
COMMENT ON COLUMN msp_subproyecto.fecha_eliminacion IS 'Fecha y hora de eliminacion logica (NULL si activo)';
COMMENT ON COLUMN msp_subproyecto.usuario_eliminacion IS 'UUID del usuario que elimino el registro (NULL si activo)';
COMMENT ON COLUMN msp_subproyecto.motivo_eliminacion IS 'Motivo de la eliminacion logica (obligatorio si fecha_eliminacion IS NOT NULL)';

-- ---------------------------------------------------------------------
-- Tabla msp_tarea (pieza ejecutable bajo subproyecto)
-- ---------------------------------------------------------------------
CREATE TABLE msp_tarea (
    id                       UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    subproyecto_id           UUID         NOT NULL REFERENCES msp_subproyecto(id),
    nombre                   VARCHAR(200) NOT NULL,
    descripcion              TEXT,
    fecha_inicio_planificada DATE         NOT NULL,
    fecha_fin_planificada    DATE         NOT NULL,
    horas_estimadas          SMALLINT     NOT NULL,
    situacion_id             UUID         NOT NULL,
    origen_variacion_id      UUID,
    estado                   SMALLINT     NOT NULL DEFAULT 1 CHECK (estado IN (0, 1)),
    fecha_creacion           TIMESTAMP    NOT NULL,
    usuario_creacion         UUID         NOT NULL,
    fecha_modificacion       TIMESTAMP,
    usuario_modificacion     UUID,
    fecha_eliminacion        TIMESTAMP,
    usuario_eliminacion      UUID,
    motivo_eliminacion       VARCHAR(500)
);

CREATE INDEX idx_msp_tarea_subproyecto ON msp_tarea(subproyecto_id);
CREATE INDEX idx_msp_tarea_situacion ON msp_tarea(situacion_id);

COMMENT ON TABLE  msp_tarea IS 'Tarea ejecutable bajo un subproyecto, con fechas planificadas y horas estimadas. Cuando todas las tareas del subproyecto estan Culminadas, el subproyecto se considera Culminado (regla de aplicacion)';
COMMENT ON COLUMN msp_tarea.id IS 'Identificador unico de la tarea';
COMMENT ON COLUMN msp_tarea.subproyecto_id IS 'FK al subproyecto al que pertenece la tarea';
COMMENT ON COLUMN msp_tarea.nombre IS 'Nombre de la tarea';
COMMENT ON COLUMN msp_tarea.descripcion IS 'Descripcion extendida de la tarea';
COMMENT ON COLUMN msp_tarea.fecha_inicio_planificada IS 'Fecha de inicio planificada de la tarea';
COMMENT ON COLUMN msp_tarea.fecha_fin_planificada IS 'Fecha de fin planificada de la tarea';
COMMENT ON COLUMN msp_tarea.horas_estimadas IS 'Horas estimadas para completar la tarea (jornada base = 8 horas)';
COMMENT ON COLUMN msp_tarea.situacion_id IS 'FK a la situacion en msa_catalogo grupo=SITUACION (Pendiente, En atencion, Culminado, Rechazado) (cross-BD)';
COMMENT ON COLUMN msp_tarea.origen_variacion_id IS 'FK a la variacion que origino esta tarea (NULL si es de la linea base original) (cross-BD a mss_variacion)';
COMMENT ON COLUMN msp_tarea.estado IS 'Estado del registro (0=inactivo, 1=activo)';
COMMENT ON COLUMN msp_tarea.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN msp_tarea.usuario_creacion IS 'UUID del usuario que creo el registro';
COMMENT ON COLUMN msp_tarea.fecha_modificacion IS 'Fecha y hora de ultima modificacion';
COMMENT ON COLUMN msp_tarea.usuario_modificacion IS 'UUID del usuario que modifico el registro';
COMMENT ON COLUMN msp_tarea.fecha_eliminacion IS 'Fecha y hora de eliminacion logica (NULL si activo)';
COMMENT ON COLUMN msp_tarea.usuario_eliminacion IS 'UUID del usuario que elimino el registro (NULL si activo)';
COMMENT ON COLUMN msp_tarea.motivo_eliminacion IS 'Motivo de la eliminacion logica (obligatorio si fecha_eliminacion IS NOT NULL)';
