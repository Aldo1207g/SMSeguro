-- =====================================================
-- SMSeguro - Equipo 6
-- Creación completa de la base de datos
-- =====================================================

-- Permite ejecutar nuevamente todo el script desde cero
DROP DATABASE IF EXISTS smseguro;

CREATE DATABASE smseguro
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE smseguro;


-- =====================================================
-- 1. TABLAS CATÁLOGO
-- =====================================================

-- Roles disponibles dentro del sistema
CREATE TABLE catalogo_rol_usuario (
    id_rol_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE
);

-- Estados posibles de un reporte
CREATE TABLE catalogo_estado_reporte (
    id_estado_reporte INT AUTO_INCREMENT PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL UNIQUE
);

-- Categorías de fraude
CREATE TABLE catalogo_tipo_fraude (
    id_tipo_fraude INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(100) NOT NULL UNIQUE
);

-- Tipos de indicadores de compromiso
CREATE TABLE catalogo_tipo_indicador (
    id_tipo_indicador INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL UNIQUE
);

-- Función que cumple un indicador dentro de un reporte
CREATE TABLE catalogo_rol_indicador (
    id_rol_indicador INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE
);

-- Posibles resoluciones de un dictamen
CREATE TABLE catalogo_resolucion (
    id_resolucion INT AUTO_INCREMENT PRIMARY KEY,
    nombre_resolucion VARCHAR(50) NOT NULL UNIQUE
);


-- =====================================================
-- 2. DATOS INICIALES DE LOS CATÁLOGOS
-- =====================================================

INSERT INTO catalogo_rol_usuario
    (id_rol_usuario, nombre_rol)
VALUES
    (1, 'Ciudadano'),
    (2, 'Analista'),
    (3, 'Administrador');

INSERT INTO catalogo_estado_reporte
    (id_estado_reporte, nombre_estado)
VALUES
    (1, 'Pendiente'),
    (2, 'Aprobado'),
    (3, 'Rechazado');

INSERT INTO catalogo_tipo_fraude
    (id_tipo_fraude, nombre_tipo)
VALUES
    (1, 'Banco'),
    (2, 'Paqueteria'),
    (3, 'Multa'),
    (4, 'Otro');

INSERT INTO catalogo_tipo_indicador
    (id_tipo_indicador, nombre_tipo)
VALUES
    (1, 'Telefono'),
    (2, 'URL');

INSERT INTO catalogo_rol_indicador
    (id_rol_indicador, nombre_rol)
VALUES
    (1, 'Remitente'),
    (2, 'Enlace'),
    (3, 'Otro');

INSERT INTO catalogo_resolucion
    (id_resolucion, nombre_resolucion)
VALUES
    (1, 'Aprobado'),
    (2, 'Rechazado');


-- =====================================================
-- 3. TABLA USUARIO
-- =====================================================

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,

    nombre_usuario VARCHAR(100) NOT NULL,

    correo_electronico VARCHAR(150) NOT NULL UNIQUE,

    contrasena_hash VARCHAR(255) NOT NULL,

    id_rol_usuario INT NOT NULL,

    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (id_rol_usuario)
        REFERENCES catalogo_rol_usuario(id_rol_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- =====================================================
-- 4. TABLA INDICADOR
-- =====================================================

CREATE TABLE indicador (
    id_indicador INT AUTO_INCREMENT PRIMARY KEY,

    id_tipo_indicador INT NOT NULL,

    valor_dato VARCHAR(255) NOT NULL UNIQUE,

    CONSTRAINT fk_indicador_tipo
        FOREIGN KEY (id_tipo_indicador)
        REFERENCES catalogo_tipo_indicador(id_tipo_indicador)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- =====================================================
-- 5. TABLA REPORTE
-- =====================================================

CREATE TABLE reporte (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,

    folio_publico CHAR(12) NOT NULL UNIQUE,

    -- Todo reporte debe pertenecer a un usuario
    id_usuario INT NOT NULL,

    -- Todo reporte inicia como Pendiente (ID 1)
    id_estado_reporte INT NOT NULL DEFAULT 1,

    id_tipo_fraude INT NULL,

    descripcion TEXT NOT NULL,

    fecha_recepcion DATETIME NULL,

    fecha_registro DATETIME NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_reporte_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_reporte_estado
        FOREIGN KEY (id_estado_reporte)
        REFERENCES catalogo_estado_reporte(id_estado_reporte)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_reporte_tipo_fraude
        FOREIGN KEY (id_tipo_fraude)
        REFERENCES catalogo_tipo_fraude(id_tipo_fraude)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- =====================================================
-- 6. TABLA CAPTURA
-- =====================================================

CREATE TABLE captura (
    id_captura INT AUTO_INCREMENT PRIMARY KEY,

    id_reporte INT NOT NULL,

    ruta_archivo VARCHAR(255) NOT NULL,

    tamano_bytes INT NOT NULL,

    mime_type VARCHAR(50) NOT NULL,

    -- SHA-256 representado en hexadecimal utiliza 64 caracteres
    hash_archivo CHAR(64) NOT NULL,

    es_publica BOOLEAN NOT NULL DEFAULT FALSE,

    -- Regla del proyecto:
    -- las capturas no pueden superar los 5 MB
    CONSTRAINT chk_tamano_captura
        CHECK (
            tamano_bytes > 0
            AND tamano_bytes <= 5242880
        ),

    CONSTRAINT fk_captura_reporte
        FOREIGN KEY (id_reporte)
        REFERENCES reporte(id_reporte)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- =====================================================
-- 7. TABLA DETALLE_REPORTE
-- Resuelve la relación N:M entre Reporte e Indicador
-- =====================================================

CREATE TABLE detalle_reporte (
    id_reporte INT NOT NULL,

    id_indicador INT NOT NULL,

    id_rol_indicador INT NOT NULL,

    PRIMARY KEY (id_reporte, id_indicador),

    CONSTRAINT fk_detalle_reporte
        FOREIGN KEY (id_reporte)
        REFERENCES reporte(id_reporte)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_detalle_indicador
        FOREIGN KEY (id_indicador)
        REFERENCES indicador(id_indicador)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_detalle_rol_indicador
        FOREIGN KEY (id_rol_indicador)
        REFERENCES catalogo_rol_indicador(id_rol_indicador)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- =====================================================
-- 8. TABLA DICTAMEN
-- =====================================================

CREATE TABLE dictamen (
    id_dictamen INT AUTO_INCREMENT PRIMARY KEY,

    -- UNIQUE garantiza que cada reporte
    -- tenga como máximo un dictamen final
    id_reporte INT NOT NULL UNIQUE,

    id_analista INT NOT NULL,

    id_resolucion INT NOT NULL,

    -- Es NULL cuando el reporte fue aprobado.
    -- Si fue rechazado, la aplicación debe exigir el motivo.
    motivo_rechazo VARCHAR(200) NULL,

    fecha_evaluacion DATETIME NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_dictamen_reporte
        FOREIGN KEY (id_reporte)
        REFERENCES reporte(id_reporte)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_dictamen_analista
        FOREIGN KEY (id_analista)
        REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_dictamen_resolucion
        FOREIGN KEY (id_resolucion)
        REFERENCES catalogo_resolucion(id_resolucion)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
