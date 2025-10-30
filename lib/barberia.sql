-- Crear base de datos (ejecutar fuera del script si ya estás en PGAdmin)
-- CREATE DATABASE stylapp;

-- Conéctate a la base de datos stylapp antes de ejecutar lo siguiente

-- =============================================
-- TABLA: roles
-- =============================================
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE -- 'cliente', 'barbero', 'administrador'
);

-- Insertar roles iniciales
INSERT INTO roles (nombre) VALUES ('cliente'), ('barbero'), ('administrador');

-- =============================================
-- TABLA: usuarios
-- =============================================
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre_completo VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    contraseña_hash TEXT NOT NULL, -- almacenar hash (ej. bcrypt)
    rol_id INT NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT true
);

-- =============================================
-- TABLA: barberos
-- =============================================
CREATE TABLE barberos (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    especialidades TEXT, -- o se puede normalizar, pero por simplicidad
    horario_inicio TIME,
    horario_fin TIME,
    dias_disponibles VARCHAR(50) -- ej: "LUN-MAR-MIE"
);

-- =============================================
-- TABLA: servicios
-- =============================================
CREATE TABLE servicios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion_minutos INT NOT NULL, -- para calcular disponibilidad
    precio DECIMAL(10, 2) NOT NULL,
    activo BOOLEAN DEFAULT true
);

-- =============================================
-- TABLA: citas
-- =============================================
CREATE TABLE citas (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    barbero_id INT NOT NULL REFERENCES barberos(id) ON DELETE RESTRICT,
    servicio_id INT NOT NULL REFERENCES servicios(id) ON DELETE RESTRICT,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    estado VARCHAR(20) DEFAULT 'pendiente', -- 'confirmada', 'cancelada', 'completada'
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cancelado_por VARCHAR(20), -- 'cliente', 'barbero', NULL
    motivo_cancelacion TEXT
);

-- Restricción: evitar duplicados en mismo barbero/hora/fecha
ALTER TABLE citas
ADD CONSTRAINT unique_barbero_hora_fecha UNIQUE (barbero_id, fecha, hora);

-- =============================================
-- TABLA: valoraciones
-- =============================================
CREATE TABLE valoraciones (
    id SERIAL PRIMARY KEY,
    cita_id INT NOT NULL REFERENCES citas(id) ON DELETE CASCADE,
    cliente_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    barbero_id INT NOT NULL REFERENCES barberos(id) ON DELETE RESTRICT,
    calificacion INT CHECK (calificacion BETWEEN 1 AND 5),
    comentario TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- TABLA: notificaciones
-- =============================================
CREATE TABLE notificaciones (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    titulo VARCHAR(100) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo VARCHAR(30), -- 'cita_confirmada', 'recordatorio', 'cancelacion', etc.
    leida BOOLEAN DEFAULT false,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- TABLA: inventario (opcional, según RF-15)
-- =============================================
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    stock INT NOT NULL DEFAULT 0,
    stock_minimo INT DEFAULT 5,
    precio DECIMAL(10, 2)
);

-- =============================================
-- TABLA: pagos
-- =============================================
CREATE TABLE pagos (
    id SERIAL PRIMARY KEY,
    cita_id INT NOT NULL REFERENCES citas(id) ON DELETE CASCADE,
    monto DECIMAL(10, 2) NOT NULL,
    metodo VARCHAR(20) NOT NULL, -- 'efectivo', 'online'
    estado VARCHAR(20) DEFAULT 'pendiente', -- 'completado', 'fallido'
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- ÍNDICES para rendimiento
-- =============================================
CREATE INDEX idx_citas_cliente ON citas(cliente_id);
CREATE INDEX idx_citas_barbero ON citas(barbero_id);
CREATE INDEX idx_citas_fecha ON citas(fecha);
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_notificaciones_usuario ON notificaciones(usuario_id);