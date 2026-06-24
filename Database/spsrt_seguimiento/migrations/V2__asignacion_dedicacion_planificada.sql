-- =====================================================================
-- Sistema      : SPSRT - Sistema de Planificacion y Seguimiento de Recursos Tecnicos
-- Modulo       : MS Seguimiento
-- Objetivo     : Anade a mss_asignacion la dedicacion estimada por periodo
--                (horas_planificadas + rango fecha_inicio/fecha_fin
--                planificada) que da soporte a la consulta de carga del
--                equipo. Cumple RF-05 (dedicacion estimada por periodo)
--                y habilita el filtro por periodo de RF-07.
-- Desarrollado : Equipo SPSRT - UNIR
-- Fecha        : 2026-06-09
-- =====================================================================

ALTER TABLE mss_asignacion ADD COLUMN horas_planificadas       NUMERIC(6, 2);
ALTER TABLE mss_asignacion ADD COLUMN fecha_inicio_planificada DATE;
ALTER TABLE mss_asignacion ADD COLUMN fecha_fin_planificada    DATE;

ALTER TABLE mss_asignacion ADD CONSTRAINT chk_mss_asign_horas_plan
    CHECK (horas_planificadas IS NULL OR horas_planificadas >= 0);

ALTER TABLE mss_asignacion ADD CONSTRAINT chk_mss_asign_periodo_plan
    CHECK (fecha_inicio_planificada IS NULL OR fecha_fin_planificada IS NULL
           OR fecha_fin_planificada >= fecha_inicio_planificada);

COMMENT ON COLUMN mss_asignacion.horas_planificadas IS 'Horas planificadas para la asignacion (carga prevista del recurso en la tarea). NULL si no se planifico';
COMMENT ON COLUMN mss_asignacion.fecha_inicio_planificada IS 'Inicio del periodo planificado de la asignacion (dedicacion estimada por periodo, RF-05). NULL si no se planifico';
COMMENT ON COLUMN mss_asignacion.fecha_fin_planificada IS 'Fin del periodo planificado de la asignacion. NULL si no se planifico';
