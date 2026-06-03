-- =====================================================================
-- Sistema      : SPSRT - Sistema de Planificacion y Seguimiento de Recursos Tecnicos
-- Modulo       : MS Administracion
-- Objetivo     : Datos semilla del MS Administracion. Carga 4 roles, 14
--                modulos del sidebar con jerarquia, 35 asignaciones
--                rol-modulo (RBAC), 23 items del catalogo unificado y
--                1 usuario administrador inicial.
-- Desarrollado : Equipo SPSRT - UNIR
-- Fecha        : 2026-05-27
-- =====================================================================
--
-- Constantes:
--   SYSTEM_USER_UUID = '00000000-0000-0000-0000-000000000000'
--     Se usa como usuario_creacion del seed (no es un usuario real).
--
-- UUIDs deterministicos para los registros core:
--   Roles:                  00000000-0000-0000-0000-00000000000X
--   Modulos:                00000000-0000-0000-0000-00000000010X
--   Usuario admin:          00000000-0000-0000-0000-000000000900
--
-- Contrasena del admin:
--   Plana   : Admin123
--   Hash    : se genera al insertar via crypt() de pgcrypto con bf (BCrypt).
--             Compatible con BCryptPasswordEncoder de Spring Security.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Roles
-- ---------------------------------------------------------------------
INSERT INTO msa_rol (id, codigo, nombre, descripcion, fecha_creacion, usuario_creacion) VALUES
('00000000-0000-0000-0000-000000000001', 'ADMIN',           'Administrador del Sistema', 'Acceso completo a la administracion (usuarios, roles, modulos, catalogo)',                                           NOW(), '00000000-0000-0000-0000-000000000000'),
('00000000-0000-0000-0000-000000000002', 'JEFE_AREA',       'Jefe del Area',             'Visualiza la carga y avance del area de desarrollo; aprueba variaciones a alto nivel',                                NOW(), '00000000-0000-0000-0000-000000000000'),
('00000000-0000-0000-0000-000000000003', 'GESTOR_PROYECTO', 'Gestor de Proyecto',        'Gestiona proyectos, subproyectos, tareas, asignaciones, congela linea base y resuelve variaciones',                  NOW(), '00000000-0000-0000-0000-000000000000'),
('00000000-0000-0000-0000-000000000004', 'RECURSO_TECNICO', 'Recurso Tecnico',           'Registra su bitacora diaria de trabajo y reporta variaciones que afecten sus tareas asignadas',                       NOW(), '00000000-0000-0000-0000-000000000000');

-- ---------------------------------------------------------------------
-- Modulos del sidebar (set base completo, con jerarquia para submenus)
-- ---------------------------------------------------------------------
-- Modulos de primer nivel
INSERT INTO msa_modulo (id, codigo, nombre, ruta, icono, orden, modulo_padre_id, descripcion, fecha_creacion, usuario_creacion) VALUES
('00000000-0000-0000-0000-000000000101', 'INICIO',          'Inicio',           '/',              'home',     1, NULL, 'Dashboard principal con indicadores generales',                                            NOW(), '00000000-0000-0000-0000-000000000000'),
('00000000-0000-0000-0000-000000000102', 'PROYECTOS',       'Proyectos',        '/proyectos',     'folder',   2, NULL, 'Gestion de sistemas, subproyectos y tareas',                                              NOW(), '00000000-0000-0000-0000-000000000000'),
('00000000-0000-0000-0000-000000000103', 'BITACORA',        'Mi Bitacora',      '/bitacora',      'journal',  3, NULL, 'Registro diario de tiempo del recurso (trabajo en tareas + actividades transversales)',  NOW(), '00000000-0000-0000-0000-000000000000'),
('00000000-0000-0000-0000-000000000104', 'ASIGNACIONES',    'Asignaciones',     '/asignaciones',  'users',    4, NULL, 'Asignacion de recursos tecnicos a tareas',                                                NOW(), '00000000-0000-0000-0000-000000000000'),
('00000000-0000-0000-0000-000000000105', 'VARIACIONES',     'Variaciones',      '/variaciones',   'edit',     5, NULL, 'Registro y resolucion de variaciones (alcance, plazo, recursos)',                         NOW(), '00000000-0000-0000-0000-000000000000'),
('00000000-0000-0000-0000-000000000106', 'LINEA_BASE',      'Linea Base',       '/linea-base',    'archive',  6, NULL, 'Snapshots congelados del plan y comparativa contra estado vigente',                       NOW(), '00000000-0000-0000-0000-000000000000'),
('00000000-0000-0000-0000-000000000107', 'ADMINISTRACION',  'Administracion',   '/admin',         'settings', 7, NULL, 'Gestion de usuarios, roles, catalogo y modulos del sistema',                              NOW(), '00000000-0000-0000-0000-000000000000');

-- Submenus de Proyectos (modulo_padre_id = 102)
INSERT INTO msa_modulo (id, codigo, nombre, ruta, icono, orden, modulo_padre_id, descripcion, fecha_creacion, usuario_creacion) VALUES
('00000000-0000-0000-0000-000000000111', 'SISTEMAS',        'Sistemas',         '/proyectos/sistemas',      'server',   1, '00000000-0000-0000-0000-000000000102', 'Catalogo de sistemas existentes y nuevos por desarrollar',                  NOW(), '00000000-0000-0000-0000-000000000000'),
('00000000-0000-0000-0000-000000000112', 'SUBPROYECTOS',    'Subproyectos',     '/proyectos/subproyectos',  'layers',   2, '00000000-0000-0000-0000-000000000102', 'Solicitudes de trabajo (incidencia, requerimiento, desarrollo modular)',    NOW(), '00000000-0000-0000-0000-000000000000'),
('00000000-0000-0000-0000-000000000113', 'TAREAS',          'Tareas',           '/proyectos/tareas',        'check',    3, '00000000-0000-0000-0000-000000000102', 'Tareas ejecutables bajo cada subproyecto',                                   NOW(), '00000000-0000-0000-0000-000000000000');

-- Submenus de Administracion (modulo_padre_id = 107)
INSERT INTO msa_modulo (id, codigo, nombre, ruta, icono, orden, modulo_padre_id, descripcion, fecha_creacion, usuario_creacion) VALUES
('00000000-0000-0000-0000-000000000121', 'USUARIOS',        'Usuarios',         '/admin/usuarios',  'user',      1, '00000000-0000-0000-0000-000000000107', 'Alta, edicion y baja de usuarios del sistema',                              NOW(), '00000000-0000-0000-0000-000000000000'),
('00000000-0000-0000-0000-000000000122', 'ROLES',           'Roles',            '/admin/roles',     'shield',    2, '00000000-0000-0000-0000-000000000107', 'Definicion de roles del sistema',                                            NOW(), '00000000-0000-0000-0000-000000000000'),
('00000000-0000-0000-0000-000000000123', 'CATALOGO',        'Catalogo',         '/admin/catalogo',  'list',      3, '00000000-0000-0000-0000-000000000107', 'Mantenimiento del catalogo unificado (tipos, prioridades, situaciones)',     NOW(), '00000000-0000-0000-0000-000000000000'),
('00000000-0000-0000-0000-000000000124', 'MODULOS',         'Modulos',          '/admin/modulos',   'grid',      4, '00000000-0000-0000-0000-000000000107', 'Mantenimiento de modulos del sidebar y asignacion por rol',                  NOW(), '00000000-0000-0000-0000-000000000000');

-- ---------------------------------------------------------------------
-- Asignaciones rol-modulo (RBAC del sidebar)
-- ---------------------------------------------------------------------
-- ADMIN: ve todos los modulos (14 filas)
INSERT INTO msa_rol_modulo (rol_id, modulo_id, fecha_creacion, usuario_creacion)
SELECT '00000000-0000-0000-0000-000000000001', m.id, NOW(), '00000000-0000-0000-0000-000000000000'
FROM msa_modulo m;

-- JEFE_AREA: ve todo excepto Administracion y sus submenus (9 filas)
INSERT INTO msa_rol_modulo (rol_id, modulo_id, fecha_creacion, usuario_creacion)
SELECT '00000000-0000-0000-0000-000000000002', m.id, NOW(), '00000000-0000-0000-0000-000000000000'
FROM msa_modulo m
WHERE m.codigo NOT IN ('ADMINISTRACION', 'USUARIOS', 'ROLES', 'CATALOGO', 'MODULOS');

-- GESTOR_PROYECTO: ve los mismos que JEFE_AREA (9 filas)
INSERT INTO msa_rol_modulo (rol_id, modulo_id, fecha_creacion, usuario_creacion)
SELECT '00000000-0000-0000-0000-000000000003', m.id, NOW(), '00000000-0000-0000-0000-000000000000'
FROM msa_modulo m
WHERE m.codigo NOT IN ('ADMINISTRACION', 'USUARIOS', 'ROLES', 'CATALOGO', 'MODULOS');

-- RECURSO_TECNICO: solo Inicio, Mi Bitacora y Variaciones (3 filas)
INSERT INTO msa_rol_modulo (rol_id, modulo_id, fecha_creacion, usuario_creacion)
SELECT '00000000-0000-0000-0000-000000000004', m.id, NOW(), '00000000-0000-0000-0000-000000000000'
FROM msa_modulo m
WHERE m.codigo IN ('INICIO', 'BITACORA', 'VARIACIONES');

-- ---------------------------------------------------------------------
-- Catalogo unificado (7 grupos)
-- ---------------------------------------------------------------------
INSERT INTO msa_catalogo (grupo, id_opcion, opcion, fecha_creacion, usuario_creacion) VALUES
-- TIPO_SUBPROYECTO
('TIPO_SUBPROYECTO',    1, 'Incidencia',           NOW(), '00000000-0000-0000-0000-000000000000'),
('TIPO_SUBPROYECTO',    2, 'Requerimiento',        NOW(), '00000000-0000-0000-0000-000000000000'),
('TIPO_SUBPROYECTO',    3, 'Desarrollo modular',   NOW(), '00000000-0000-0000-0000-000000000000'),
-- PRIORIDAD
('PRIORIDAD',           1, 'Alta',                 NOW(), '00000000-0000-0000-0000-000000000000'),
('PRIORIDAD',           2, 'Media',                NOW(), '00000000-0000-0000-0000-000000000000'),
('PRIORIDAD',           3, 'Baja',                 NOW(), '00000000-0000-0000-0000-000000000000'),
-- SITUACION (subproyecto y tarea)
('SITUACION',           1, 'Pendiente',            NOW(), '00000000-0000-0000-0000-000000000000'),
('SITUACION',           2, 'En atencion',          NOW(), '00000000-0000-0000-0000-000000000000'),
('SITUACION',           3, 'Culminado',            NOW(), '00000000-0000-0000-0000-000000000000'),
('SITUACION',           4, 'Rechazado',            NOW(), '00000000-0000-0000-0000-000000000000'),
-- TIPO_VARIACION
('TIPO_VARIACION',      1, 'Alcance',              NOW(), '00000000-0000-0000-0000-000000000000'),
('TIPO_VARIACION',      2, 'Plazo',                NOW(), '00000000-0000-0000-0000-000000000000'),
('TIPO_VARIACION',      3, 'Recursos',             NOW(), '00000000-0000-0000-0000-000000000000'),
-- SITUACION_VARIACION
('SITUACION_VARIACION', 1, 'Pendiente',            NOW(), '00000000-0000-0000-0000-000000000000'),
('SITUACION_VARIACION', 2, 'Aprobada',             NOW(), '00000000-0000-0000-0000-000000000000'),
('SITUACION_VARIACION', 3, 'Rechazada',            NOW(), '00000000-0000-0000-0000-000000000000'),
-- TIPO_ACTIVIDAD
('TIPO_ACTIVIDAD',      1, 'Reunion',              NOW(), '00000000-0000-0000-0000-000000000000'),
('TIPO_ACTIVIDAD',      2, 'Capacitacion',         NOW(), '00000000-0000-0000-0000-000000000000'),
('TIPO_ACTIVIDAD',      3, 'Soporte',              NOW(), '00000000-0000-0000-0000-000000000000'),
('TIPO_ACTIVIDAD',      4, 'Otro',                 NOW(), '00000000-0000-0000-0000-000000000000'),
-- MODALIDAD
('MODALIDAD',           1, 'Presencial',           NOW(), '00000000-0000-0000-0000-000000000000'),
('MODALIDAD',           2, 'Virtual',              NOW(), '00000000-0000-0000-0000-000000000000'),
('MODALIDAD',           3, 'Hibrida',              NOW(), '00000000-0000-0000-0000-000000000000');

-- ---------------------------------------------------------------------
-- Usuario administrador inicial
-- ---------------------------------------------------------------------
-- Email      : admin@srp.local
-- Contrasena : Admin123 (hasheada en linea con crypt() de pgcrypto, algoritmo bf=BCrypt)
-- Rol        : ADMIN
INSERT INTO msa_usuario (id, email, contrasenia, nombres, apellido_paterno, apellido_materno, rol_id, fecha_creacion, usuario_creacion) VALUES
('00000000-0000-0000-0000-000000000900',
 'admin@srp.local',
 crypt('Admin123', gen_salt('bf', 10)),
 'Administrador',
 'del',
 'Sistema',
 '00000000-0000-0000-0000-000000000001',
 NOW(),
 '00000000-0000-0000-0000-000000000000');
