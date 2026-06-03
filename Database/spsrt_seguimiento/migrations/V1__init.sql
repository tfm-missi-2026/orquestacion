-- =====================================================================
-- Sistema      : SPSRT - Sistema de Planificacion y Seguimiento de Recursos Tecnicos
-- Modulo       : MS Seguimiento
-- Objetivo     : Esquema inicial del MS Seguimiento. Crea las 7 tablas
--                (mss_asignacion, mss_actividad, mss_bitacora,
--                mss_variacion, mss_linea_base, mss_lb_tarea,
--                mss_lb_asignacion) con sus indices, restricciones y
--                comentarios.
-- Desarrollado : Equipo SPSRT - UNIR
-- Fecha        : 2026-05-27
-- =====================================================================

-- ---------------------------------------------------------------------
-- Extension requerida para gen_random_uuid() (PK uuid de todas las tablas)
-- ---------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------------------------------------------------------------------
-- Tabla mss_asignacion
-- ---------------------------------------------------------------------
CREATE TABLE mss_asignacion (
    id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    tarea_id             UUID         NOT NULL,
    usuario_id           UUID         NOT NULL,
    estado               SMALLINT     NOT NULL DEFAULT 1 CHECK (estado IN (0, 1)),
    fecha_creacion       TIMESTAMP    NOT NULL,
    usuario_creacion     UUID         NOT NULL,
    fecha_modificacion   TIMESTAMP,
    usuario_modificacion UUID,
    fecha_eliminacion    TIMESTAMP,
    usuario_eliminacion  UUID,
    motivo_eliminacion   VARCHAR(500)
);

CREATE UNIQUE INDEX uk_mss_asign_tarea_usuario ON mss_asignacion(tarea_id, usuario_id);
CREATE INDEX idx_mss_asign_tarea ON mss_asignacion(tarea_id);
CREATE INDEX idx_mss_asign_usuario ON mss_asignacion(usuario_id);

COMMENT ON TABLE  mss_asignacion IS 'Asignacion de recurso tecnico a tarea (que tarea ejecuta cada recurso). Las horas estimadas viven en msp_tarea';
COMMENT ON COLUMN mss_asignacion.id IS 'Identificador unico de la asignacion';
COMMENT ON COLUMN mss_asignacion.tarea_id IS 'UUID de la tarea (cross-BD a msp_tarea, sin FK)';
COMMENT ON COLUMN mss_asignacion.usuario_id IS 'UUID del recurso asignado (cross-BD a msa_usuario, sin FK)';
COMMENT ON COLUMN mss_asignacion.estado IS 'Estado del registro (0=inactivo, 1=activo)';
COMMENT ON COLUMN mss_asignacion.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN mss_asignacion.usuario_creacion IS 'UUID del usuario que creo el registro';
COMMENT ON COLUMN mss_asignacion.fecha_modificacion IS 'Fecha y hora de ultima modificacion';
COMMENT ON COLUMN mss_asignacion.usuario_modificacion IS 'UUID del usuario que modifico el registro';
COMMENT ON COLUMN mss_asignacion.fecha_eliminacion IS 'Fecha y hora de eliminacion logica (NULL si activo)';
COMMENT ON COLUMN mss_asignacion.usuario_eliminacion IS 'UUID del usuario que elimino el registro (NULL si activo)';
COMMENT ON COLUMN mss_asignacion.motivo_eliminacion IS 'Motivo de la eliminacion logica (obligatorio si fecha_eliminacion IS NOT NULL)';

-- ---------------------------------------------------------------------
-- Tabla mss_actividad
-- ---------------------------------------------------------------------
CREATE TABLE mss_actividad (
    id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    tipo_actividad_id    UUID         NOT NULL,
    modalidad_id         UUID         NOT NULL,
    titulo               VARCHAR(200) NOT NULL,
    descripcion          TEXT,
    fecha                DATE         NOT NULL,
    hora_inicio          TIME         NOT NULL,
    hora_fin             TIME         NOT NULL,
    organizador_id       UUID         NOT NULL,
    estado               SMALLINT     NOT NULL DEFAULT 1 CHECK (estado IN (0, 1)),
    fecha_creacion       TIMESTAMP    NOT NULL,
    usuario_creacion     UUID         NOT NULL,
    fecha_modificacion   TIMESTAMP,
    usuario_modificacion UUID,
    fecha_eliminacion    TIMESTAMP,
    usuario_eliminacion  UUID,
    motivo_eliminacion   VARCHAR(500)
);

CREATE INDEX idx_mss_act_fecha ON mss_actividad(fecha);
CREATE INDEX idx_mss_act_tipo ON mss_actividad(tipo_actividad_id);
CREATE INDEX idx_mss_act_organizador ON mss_actividad(organizador_id);

COMMENT ON TABLE  mss_actividad IS 'Definicion de actividades fuera de subproyecto (reuniones, capacitaciones, soporte general). Los participantes se infieren de las entradas en mss_bitacora con actividad_id';
COMMENT ON COLUMN mss_actividad.id IS 'Identificador unico de la actividad';
COMMENT ON COLUMN mss_actividad.tipo_actividad_id IS 'FK al tipo en msa_catalogo grupo=TIPO_ACTIVIDAD (Reunion, Capacitacion, Soporte, Otro) (cross-BD)';
COMMENT ON COLUMN mss_actividad.modalidad_id IS 'FK a la modalidad en msa_catalogo grupo=MODALIDAD (Presencial, Virtual, Hibrida) (cross-BD)';
COMMENT ON COLUMN mss_actividad.titulo IS 'Titulo de la actividad';
COMMENT ON COLUMN mss_actividad.descripcion IS 'Descripcion o agenda de la actividad';
COMMENT ON COLUMN mss_actividad.fecha IS 'Dia en que se realiza la actividad';
COMMENT ON COLUMN mss_actividad.hora_inicio IS 'Hora de inicio planificada de la actividad';
COMMENT ON COLUMN mss_actividad.hora_fin IS 'Hora de fin planificada de la actividad';
COMMENT ON COLUMN mss_actividad.organizador_id IS 'UUID del organizador (cross-BD a msa_usuario)';
COMMENT ON COLUMN mss_actividad.estado IS 'Estado del registro (0=inactivo, 1=activo)';
COMMENT ON COLUMN mss_actividad.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN mss_actividad.usuario_creacion IS 'UUID del usuario que creo el registro';
COMMENT ON COLUMN mss_actividad.fecha_modificacion IS 'Fecha y hora de ultima modificacion';
COMMENT ON COLUMN mss_actividad.usuario_modificacion IS 'UUID del usuario que modifico el registro';
COMMENT ON COLUMN mss_actividad.fecha_eliminacion IS 'Fecha y hora de eliminacion logica (NULL si activo)';
COMMENT ON COLUMN mss_actividad.usuario_eliminacion IS 'UUID del usuario que elimino el registro (NULL si activo)';
COMMENT ON COLUMN mss_actividad.motivo_eliminacion IS 'Motivo de la eliminacion logica (obligatorio si fecha_eliminacion IS NOT NULL)';

-- ---------------------------------------------------------------------
-- Tabla mss_bitacora
-- ---------------------------------------------------------------------
CREATE TABLE mss_bitacora (
    id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id           UUID         NOT NULL,
    fecha                DATE         NOT NULL,
    hora_inicio          TIME         NOT NULL,
    hora_fin             TIME         NOT NULL,
    descripcion          VARCHAR(500),
    asignacion_id        UUID         REFERENCES mss_asignacion(id),
    actividad_id         UUID         REFERENCES mss_actividad(id),
    estado               SMALLINT     NOT NULL DEFAULT 1 CHECK (estado IN (0, 1)),
    fecha_creacion       TIMESTAMP    NOT NULL,
    usuario_creacion     UUID         NOT NULL,
    fecha_modificacion   TIMESTAMP,
    usuario_modificacion UUID,
    fecha_eliminacion    TIMESTAMP,
    usuario_eliminacion  UUID,
    motivo_eliminacion   VARCHAR(500),
    CONSTRAINT chk_mss_bitacora_xor CHECK (
        (asignacion_id IS NOT NULL AND actividad_id IS NULL) OR
        (asignacion_id IS NULL AND actividad_id IS NOT NULL)
    )
);

CREATE UNIQUE INDEX uk_mss_bit_usuario_fecha_hini ON mss_bitacora(usuario_id, fecha, hora_inicio);
CREATE INDEX idx_mss_bit_usuario ON mss_bitacora(usuario_id);
CREATE INDEX idx_mss_bit_fecha ON mss_bitacora(fecha);
CREATE INDEX idx_mss_bit_asignacion ON mss_bitacora(asignacion_id);
CREATE INDEX idx_mss_bit_actividad ON mss_bitacora(actividad_id);

COMMENT ON TABLE  mss_bitacora IS 'Bitacora diaria del desarrollador: cada bloque es trabajo en tarea (via asignacion_id) o participacion en actividad (via actividad_id). CHECK: (asignacion_id IS NOT NULL) XOR (actividad_id IS NOT NULL). La carga total del dia se obtiene sumando hora_fin - hora_inicio';
COMMENT ON COLUMN mss_bitacora.id IS 'Identificador unico de la entrada de bitacora';
COMMENT ON COLUMN mss_bitacora.usuario_id IS 'UUID del dueno de la entrada (cross-BD a msa_usuario)';
COMMENT ON COLUMN mss_bitacora.fecha IS 'Dia del bloque registrado';
COMMENT ON COLUMN mss_bitacora.hora_inicio IS 'Hora de inicio del bloque';
COMMENT ON COLUMN mss_bitacora.hora_fin IS 'Hora de fin del bloque';
COMMENT ON COLUMN mss_bitacora.descripcion IS 'Descripcion del trabajo o participacion realizada';
COMMENT ON COLUMN mss_bitacora.asignacion_id IS 'FK a la asignacion si la entrada es trabajo en tarea (NULL si es actividad)';
COMMENT ON COLUMN mss_bitacora.actividad_id IS 'FK a la actividad si la entrada es participacion en actividad (NULL si es trabajo en tarea)';
COMMENT ON COLUMN mss_bitacora.estado IS 'Estado del registro (0=inactivo, 1=activo)';
COMMENT ON COLUMN mss_bitacora.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN mss_bitacora.usuario_creacion IS 'UUID del usuario que creo el registro';
COMMENT ON COLUMN mss_bitacora.fecha_modificacion IS 'Fecha y hora de ultima modificacion';
COMMENT ON COLUMN mss_bitacora.usuario_modificacion IS 'UUID del usuario que modifico el registro';
COMMENT ON COLUMN mss_bitacora.fecha_eliminacion IS 'Fecha y hora de eliminacion logica (NULL si activo)';
COMMENT ON COLUMN mss_bitacora.usuario_eliminacion IS 'UUID del usuario que elimino el registro (NULL si activo)';
COMMENT ON COLUMN mss_bitacora.motivo_eliminacion IS 'Motivo de la eliminacion logica (obligatorio si fecha_eliminacion IS NOT NULL)';

-- ---------------------------------------------------------------------
-- Tabla mss_variacion
-- ---------------------------------------------------------------------
CREATE TABLE mss_variacion (
    id                     UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    tarea_id               UUID,
    tipo_variacion_id      UUID         NOT NULL,
    descripcion            TEXT         NOT NULL,
    justificacion          TEXT         NOT NULL,
    valor_anterior         VARCHAR(500),
    valor_nuevo            VARCHAR(500),
    fecha_deteccion        DATE         NOT NULL,
    reportada_por          UUID         NOT NULL,
    situacion_id           UUID         NOT NULL,
    observacion_resolucion VARCHAR(500),
    fecha_resolucion       TIMESTAMP,
    resuelto_por           UUID,
    estado                 SMALLINT     NOT NULL DEFAULT 1 CHECK (estado IN (0, 1)),
    fecha_creacion         TIMESTAMP    NOT NULL,
    usuario_creacion       UUID         NOT NULL,
    fecha_modificacion     TIMESTAMP,
    usuario_modificacion   UUID,
    fecha_eliminacion      TIMESTAMP,
    usuario_eliminacion    UUID,
    motivo_eliminacion     VARCHAR(500)
);

CREATE INDEX idx_mss_var_tarea ON mss_variacion(tarea_id);
CREATE INDEX idx_mss_var_situacion ON mss_variacion(situacion_id);

COMMENT ON TABLE  mss_variacion IS 'Variaciones formales sobre la planificacion (alcance, plazo o recursos) - cumple RF-10/RF-11';
COMMENT ON COLUMN mss_variacion.id IS 'Identificador unico de la variacion';
COMMENT ON COLUMN mss_variacion.tarea_id IS 'UUID de la tarea afectada (cross-BD a msp_tarea, NULL si la variacion es a nivel subproyecto/proyecto)';
COMMENT ON COLUMN mss_variacion.tipo_variacion_id IS 'FK al tipo en msa_catalogo grupo=TIPO_VARIACION (cross-BD)';
COMMENT ON COLUMN mss_variacion.descripcion IS 'Descripcion del cambio solicitado';
COMMENT ON COLUMN mss_variacion.justificacion IS 'Justificacion obligatoria del cambio (RF-10)';
COMMENT ON COLUMN mss_variacion.valor_anterior IS 'Estado del atributo afectado antes del cambio';
COMMENT ON COLUMN mss_variacion.valor_nuevo IS 'Estado del atributo afectado despues del cambio';
COMMENT ON COLUMN mss_variacion.fecha_deteccion IS 'Fecha en que se identifico la necesidad de la variacion';
COMMENT ON COLUMN mss_variacion.reportada_por IS 'UUID del actor que reporto la variacion (cross-BD a msa_usuario)';
COMMENT ON COLUMN mss_variacion.situacion_id IS 'FK a la situacion en msa_catalogo grupo=SITUACION_VARIACION (Pendiente, Aprobada, Rechazada) (cross-BD)';
COMMENT ON COLUMN mss_variacion.observacion_resolucion IS 'Comentario de quien aprueba/rechaza (motivo si rechaza)';
COMMENT ON COLUMN mss_variacion.fecha_resolucion IS 'Fecha y hora en que se aprobo o rechazo';
COMMENT ON COLUMN mss_variacion.resuelto_por IS 'UUID del Gestor que decidio (cross-BD a msa_usuario)';
COMMENT ON COLUMN mss_variacion.estado IS 'Estado del registro (0=inactivo, 1=activo)';
COMMENT ON COLUMN mss_variacion.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN mss_variacion.usuario_creacion IS 'UUID del usuario que creo el registro';
COMMENT ON COLUMN mss_variacion.fecha_modificacion IS 'Fecha y hora de ultima modificacion';
COMMENT ON COLUMN mss_variacion.usuario_modificacion IS 'UUID del usuario que modifico el registro';
COMMENT ON COLUMN mss_variacion.fecha_eliminacion IS 'Fecha y hora de eliminacion logica (NULL si activo)';
COMMENT ON COLUMN mss_variacion.usuario_eliminacion IS 'UUID del usuario que elimino el registro (NULL si activo)';
COMMENT ON COLUMN mss_variacion.motivo_eliminacion IS 'Motivo de la eliminacion logica (obligatorio si fecha_eliminacion IS NOT NULL)';

-- ---------------------------------------------------------------------
-- Tabla mss_linea_base (cabecera)
-- ---------------------------------------------------------------------
CREATE TABLE mss_linea_base (
    id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    proyecto_id          UUID         NOT NULL,
    version              SMALLINT     NOT NULL,
    descripcion          VARCHAR(500),
    fecha_congelacion    TIMESTAMP    NOT NULL,
    congelada_por        UUID         NOT NULL,
    estado               SMALLINT     NOT NULL DEFAULT 1 CHECK (estado IN (0, 1)),
    fecha_creacion       TIMESTAMP    NOT NULL,
    usuario_creacion     UUID         NOT NULL,
    fecha_modificacion   TIMESTAMP,
    usuario_modificacion UUID,
    fecha_eliminacion    TIMESTAMP,
    usuario_eliminacion  UUID,
    motivo_eliminacion   VARCHAR(500)
);

CREATE UNIQUE INDEX uk_mss_lb_proyecto_version ON mss_linea_base(proyecto_id, version);
CREATE INDEX idx_mss_lb_proyecto ON mss_linea_base(proyecto_id);

COMMENT ON TABLE  mss_linea_base IS 'Linea base de planificacion: fotografia congelada del plan al momento de aprobacion (1er entregable, seccion 2.2)';
COMMENT ON COLUMN mss_linea_base.id IS 'Identificador unico de la linea base';
COMMENT ON COLUMN mss_linea_base.proyecto_id IS 'UUID del sistema (cross-BD a msp_proyecto)';
COMMENT ON COLUMN mss_linea_base.version IS 'Numero de version de la linea base (1=plan inicial, 2+ tras re-planificaciones aprobadas)';
COMMENT ON COLUMN mss_linea_base.descripcion IS 'Descripcion de la linea base';
COMMENT ON COLUMN mss_linea_base.fecha_congelacion IS 'Fecha y hora en que se congelo la linea base';
COMMENT ON COLUMN mss_linea_base.congelada_por IS 'UUID del Gestor que congelo la linea base (cross-BD a msa_usuario)';
COMMENT ON COLUMN mss_linea_base.estado IS 'Estado del registro (0=inactivo, 1=activo)';
COMMENT ON COLUMN mss_linea_base.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN mss_linea_base.usuario_creacion IS 'UUID del usuario que creo el registro';
COMMENT ON COLUMN mss_linea_base.fecha_modificacion IS 'Fecha y hora de ultima modificacion';
COMMENT ON COLUMN mss_linea_base.usuario_modificacion IS 'UUID del usuario que modifico el registro';
COMMENT ON COLUMN mss_linea_base.fecha_eliminacion IS 'Fecha y hora de eliminacion logica (NULL si activo)';
COMMENT ON COLUMN mss_linea_base.usuario_eliminacion IS 'UUID del usuario que elimino el registro (NULL si activo)';
COMMENT ON COLUMN mss_linea_base.motivo_eliminacion IS 'Motivo de la eliminacion logica (obligatorio si fecha_eliminacion IS NOT NULL)';

-- ---------------------------------------------------------------------
-- Tabla mss_lb_tarea (detalle: snapshot de tareas)
-- ---------------------------------------------------------------------
CREATE TABLE mss_lb_tarea (
    id                       UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    linea_base_id            UUID         NOT NULL REFERENCES mss_linea_base(id),
    tarea_id                 UUID         NOT NULL,
    nombre                   VARCHAR(200) NOT NULL,
    descripcion              TEXT,
    fecha_inicio_planificada DATE         NOT NULL,
    fecha_fin_planificada    DATE         NOT NULL,
    horas_estimadas          SMALLINT     NOT NULL,
    estado                   SMALLINT     NOT NULL DEFAULT 1 CHECK (estado IN (0, 1)),
    fecha_creacion           TIMESTAMP    NOT NULL,
    usuario_creacion         UUID         NOT NULL,
    fecha_modificacion       TIMESTAMP,
    usuario_modificacion     UUID,
    fecha_eliminacion        TIMESTAMP,
    usuario_eliminacion      UUID,
    motivo_eliminacion       VARCHAR(500)
);

CREATE INDEX idx_mss_lbt_lb ON mss_lb_tarea(linea_base_id);
CREATE INDEX idx_mss_lbt_tarea ON mss_lb_tarea(tarea_id);

COMMENT ON TABLE  mss_lb_tarea IS 'Snapshot de cada tarea al momento de congelar la linea base';
COMMENT ON COLUMN mss_lb_tarea.id IS 'Identificador unico del snapshot de tarea';
COMMENT ON COLUMN mss_lb_tarea.linea_base_id IS 'FK a la linea base (intra-BD)';
COMMENT ON COLUMN mss_lb_tarea.tarea_id IS 'UUID de la tarea original (cross-BD a msp_tarea)';
COMMENT ON COLUMN mss_lb_tarea.nombre IS 'Nombre de la tarea al momento de congelar';
COMMENT ON COLUMN mss_lb_tarea.descripcion IS 'Descripcion de la tarea al momento de congelar';
COMMENT ON COLUMN mss_lb_tarea.fecha_inicio_planificada IS 'Fecha de inicio planificada al momento de congelar';
COMMENT ON COLUMN mss_lb_tarea.fecha_fin_planificada IS 'Fecha de fin planificada al momento de congelar';
COMMENT ON COLUMN mss_lb_tarea.horas_estimadas IS 'Horas estimadas al momento de congelar (jornada base = 8 horas)';
COMMENT ON COLUMN mss_lb_tarea.estado IS 'Estado del registro (0=inactivo, 1=activo)';
COMMENT ON COLUMN mss_lb_tarea.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN mss_lb_tarea.usuario_creacion IS 'UUID del usuario que creo el registro';
COMMENT ON COLUMN mss_lb_tarea.fecha_modificacion IS 'Fecha y hora de ultima modificacion';
COMMENT ON COLUMN mss_lb_tarea.usuario_modificacion IS 'UUID del usuario que modifico el registro';
COMMENT ON COLUMN mss_lb_tarea.fecha_eliminacion IS 'Fecha y hora de eliminacion logica (NULL si activo)';
COMMENT ON COLUMN mss_lb_tarea.usuario_eliminacion IS 'UUID del usuario que elimino el registro (NULL si activo)';
COMMENT ON COLUMN mss_lb_tarea.motivo_eliminacion IS 'Motivo de la eliminacion logica (obligatorio si fecha_eliminacion IS NOT NULL)';

-- ---------------------------------------------------------------------
-- Tabla mss_lb_asignacion (detalle: snapshot de asignaciones)
-- ---------------------------------------------------------------------
CREATE TABLE mss_lb_asignacion (
    id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    linea_base_id        UUID         NOT NULL REFERENCES mss_linea_base(id),
    asignacion_id        UUID         NOT NULL REFERENCES mss_asignacion(id),
    tarea_id             UUID         NOT NULL,
    usuario_id           UUID         NOT NULL,
    estado               SMALLINT     NOT NULL DEFAULT 1 CHECK (estado IN (0, 1)),
    fecha_creacion       TIMESTAMP    NOT NULL,
    usuario_creacion     UUID         NOT NULL,
    fecha_modificacion   TIMESTAMP,
    usuario_modificacion UUID,
    fecha_eliminacion    TIMESTAMP,
    usuario_eliminacion  UUID,
    motivo_eliminacion   VARCHAR(500)
);

CREATE INDEX idx_mss_lba_lb ON mss_lb_asignacion(linea_base_id);
CREATE INDEX idx_mss_lba_asignacion ON mss_lb_asignacion(asignacion_id);

COMMENT ON TABLE  mss_lb_asignacion IS 'Snapshot de cada asignacion al momento de congelar la linea base';
COMMENT ON COLUMN mss_lb_asignacion.id IS 'Identificador unico del snapshot de asignacion';
COMMENT ON COLUMN mss_lb_asignacion.linea_base_id IS 'FK a la linea base (intra-BD)';
COMMENT ON COLUMN mss_lb_asignacion.asignacion_id IS 'FK a la asignacion original (intra-BD)';
COMMENT ON COLUMN mss_lb_asignacion.tarea_id IS 'UUID de la tarea (cross-BD a msp_tarea, denormalizado)';
COMMENT ON COLUMN mss_lb_asignacion.usuario_id IS 'UUID del recurso (cross-BD a msa_usuario, denormalizado)';
COMMENT ON COLUMN mss_lb_asignacion.estado IS 'Estado del registro (0=inactivo, 1=activo)';
COMMENT ON COLUMN mss_lb_asignacion.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN mss_lb_asignacion.usuario_creacion IS 'UUID del usuario que creo el registro';
COMMENT ON COLUMN mss_lb_asignacion.fecha_modificacion IS 'Fecha y hora de ultima modificacion';
COMMENT ON COLUMN mss_lb_asignacion.usuario_modificacion IS 'UUID del usuario que modifico el registro';
COMMENT ON COLUMN mss_lb_asignacion.fecha_eliminacion IS 'Fecha y hora de eliminacion logica (NULL si activo)';
COMMENT ON COLUMN mss_lb_asignacion.usuario_eliminacion IS 'UUID del usuario que elimino el registro (NULL si activo)';
COMMENT ON COLUMN mss_lb_asignacion.motivo_eliminacion IS 'Motivo de la eliminacion logica (obligatorio si fecha_eliminacion IS NOT NULL)';
