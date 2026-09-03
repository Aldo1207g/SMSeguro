-- -----------------------------------------------------
-- Creación de la base de datos SMSeguro (Equipo 6)
-- Versión Mejorada: Escalabilidad con Tablas Catálogo
-- -----------------------------------------------------
CREATE DATABASE IF NOT EXISTS smseguro;
USE smseguro;

-- =====================================================
-- 1. TABLAS CATÁLOGO (Las "mini tablitas" de configuración)
-- =====================================================

CREATE TABLE catalogo_rol_usuario (
    id_rol_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE catalogo_estado_reporte (
    id_estado_reporte INT AUTO_INCREMENT PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE catalogo_tipo_fraude (
    id_tipo_fraude INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE catalogo_tipo_indicador (
    id_tipo_indicador INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE catalogo_rol_indicador (
    id_rol_indicador INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE catalogo_resolucion (
    id_resolucion INT AUTO_INCREMENT PRIMARY KEY,
    nombre_resolucion VARCHAR(50) NOT NULL UNIQUE
);

-- =====================================================
-- 2. TABLAS PRINCIPALES (Conectadas con JOINs / INTs)
-- =====================================================

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre_usuario VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(150) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    id_rol_usuario INT NOT NULL,
    FOREIGN KEY (id_rol_usuario) REFERENCES catalogo_rol_usuario(id_rol_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE indicador (
    id_indicador INT AUTO_INCREMENT PRIMARY KEY,
    id_tipo_indicador INT NOT NULL,
    valor_dato VARCHAR(255) NOT NULL UNIQUE,
    FOREIGN KEY (id_tipo_indicador) REFERENCES catalogo_tipo_indicador(id_tipo_indicador) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE reporte (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    folio_publico CHAR(12) NOT NULL UNIQUE,
    id_usuario INT NULL,
    id_estado_reporte INT NOT NULL,
    id_tipo_fraude INT NULL,
    descripcion TEXT NOT NULL,
    fecha_recepcion DATETIME NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id_estado_reporte) REFERENCES catalogo_estado_reporte(id_estado_reporte) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_tipo_fraude) REFERENCES catalogo_tipo_fraude(id_tipo_fraude) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE captura (
    id_captura INT AUTO_INCREMENT PRIMARY KEY,
    id_reporte INT NOT NULL,
    ruta_archivo VARCHAR(255) NOT NULL,
    tamano_bytes INT NOT NULL,
    mime_type VARCHAR(50) NOT NULL,
    hash_archivo CHAR(64) NOT NULL,
    es_publica BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (id_reporte) REFERENCES reporte(id_reporte) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla pivote entre Reporte e Indicador
CREATE TABLE detalle_reporte (
    id_reporte INT NOT NULL,
    id_indicador INT NOT NULL,
    id_rol_indicador INT NOT NULL,
    PRIMARY KEY (id_reporte, id_indicador),
    FOREIGN KEY (id_reporte) REFERENCES reporte(id_reporte) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_indicador) REFERENCES indicador(id_indicador) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_rol_indicador) REFERENCES catalogo_rol_indicador(id_rol_indicador) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE dictamen (
    id_dictamen INT AUTO_INCREMENT PRIMARY KEY,
    id_reporte INT NOT NULL UNIQUE,
    id_analista INT NOT NULL,
    id_resolucion INT NOT NULL,
    motivo_rechazo VARCHAR(200) NULL,
    fecha_evaluacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_reporte) REFERENCES reporte(id_reporte) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_analista) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_resolucion) REFERENCES catalogo_resolucion(id_resolucion) ON DELETE RESTRICT ON UPDATE CASCADE
);