-- -----------------------------------------------------
-- Creación de la base de datos SMSeguro (Equipo 6)
-- -----------------------------------------------------
CREATE DATABASE IF NOT EXISTS smseguro;
USE smseguro;

-- -----------------------------------------------------
-- Tabla: usuario
-- -----------------------------------------------------
CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre_usuario VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(150) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    rol_usuario ENUM('Ciudadano', 'Analista') NOT NULL
);

-- -----------------------------------------------------
-- Tabla: indicador (Se crea antes porque no tiene dependencias)
-- -----------------------------------------------------
CREATE TABLE indicador (
    id_indicador INT AUTO_INCREMENT PRIMARY KEY,
    tipo_dato ENUM('Tel', 'URL') NOT NULL,
    valor_dato VARCHAR(255) NOT NULL UNIQUE
);

-- -----------------------------------------------------
-- Tabla: reporte
-- -----------------------------------------------------
CREATE TABLE reporte (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    folio_publico CHAR(12) NOT NULL UNIQUE,
    id_usuario INT NULL,
    estado ENUM('Pendiente', 'Aprobado', 'Rechazado') NOT NULL DEFAULT 'Pendiente',
    tipo_fraude ENUM('Banco', 'Paqueteria', 'Multa', 'Otro') NULL,
    descripcion TEXT NOT NULL,
    fecha_recepcion DATETIME NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE SET NULL ON UPDATE CASCADE
);

-- -----------------------------------------------------
-- Tabla: captura
-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- Tabla: detalle_reporte (Resolución N:M)
-- -----------------------------------------------------
CREATE TABLE detalle_reporte (
    id_reporte INT NOT NULL,
    id_indicador INT NOT NULL,
    rol ENUM('Remitente', 'Enlace', 'Otro') NOT NULL,
    PRIMARY KEY (id_reporte, id_indicador),
    FOREIGN KEY (id_reporte) REFERENCES reporte(id_reporte) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_indicador) REFERENCES indicador(id_indicador) ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------
-- Tabla: dictamen
-- -----------------------------------------------------
CREATE TABLE dictamen (
    id_dictamen INT AUTO_INCREMENT PRIMARY KEY,
    id_reporte INT NOT NULL UNIQUE,
    id_analista INT NOT NULL,
    dictamen_estatus ENUM('Aprobado', 'Rechazado') NOT NULL,
    motivo_rechazo VARCHAR(200) NULL,
    fecha_evaluacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_reporte) REFERENCES reporte(id_reporte) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_analista) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_motivo CHECK (dictamen_estatus <> 'Rechazado' OR motivo_rechazo IS NOT NULL)
);