-- =====================================================================
-- Sistema      : SPSRT - Sistema de Planificacion y Seguimiento de Recursos Tecnicos
-- Modulo       : Bootstrap del cluster PostgreSQL
-- Objetivo     : Crea las tres bases logicas y los usuarios de aplicacion
--                que cada microservicio usa para conectarse. Lo ejecuta
--                postgres:16 al primer arranque via docker-entrypoint-initdb.d.
-- Desarrollado : Equipo SPSRT - UNIR
-- Fecha        : 2026-05-27
-- =====================================================================

-- Usuarios de aplicacion (uno por microservicio para aislar permisos).
CREATE USER spsrt_administracion_user WITH ENCRYPTED PASSWORD 'spsrt_administracion_pwd';
CREATE USER spsrt_proyectos_user      WITH ENCRYPTED PASSWORD 'spsrt_proyectos_pwd';
CREATE USER spsrt_seguimiento_user    WITH ENCRYPTED PASSWORD 'spsrt_seguimiento_pwd';

-- Bases logicas (una por microservicio - RNF-08).
CREATE DATABASE spsrt_administracion OWNER spsrt_administracion_user ENCODING 'UTF8';
CREATE DATABASE spsrt_proyectos      OWNER spsrt_proyectos_user      ENCODING 'UTF8';
CREATE DATABASE spsrt_seguimiento    OWNER spsrt_seguimiento_user    ENCODING 'UTF8';

-- pgcrypto habilita gen_random_uuid() para PK uuid.
\connect spsrt_administracion
CREATE EXTENSION IF NOT EXISTS pgcrypto;
GRANT ALL PRIVILEGES ON SCHEMA public TO spsrt_administracion_user;

\connect spsrt_proyectos
CREATE EXTENSION IF NOT EXISTS pgcrypto;
GRANT ALL PRIVILEGES ON SCHEMA public TO spsrt_proyectos_user;

\connect spsrt_seguimiento
CREATE EXTENSION IF NOT EXISTS pgcrypto;
GRANT ALL PRIVILEGES ON SCHEMA public TO spsrt_seguimiento_user;
