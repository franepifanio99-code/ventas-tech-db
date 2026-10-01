-- Para que el script borre la versión anterior y cree todo desde cero:

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'Ventas_Tech_DB')
BEGIN
    ALTER DATABASE Ventas_Tech_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Ventas_Tech_DB;
END;
GO

-- Creacion de la base de datos
CREATE DATABASE Ventas_Tech_DB;
GO

-- Seleccion de la base de datos
USE Ventas_Tech_DB;
GO

-- Seccion 1: Drop Tables
-- Orden inverso a las dependencias (primero la tabla de hechos)

IF OBJECT_ID('dbo.ventas', 'U') IS NOT NULL DROP TABLE dbo.ventas;
IF OBJECT_ID('dbo.productos', 'U') IS NOT NULL DROP TABLE dbo.productos;
IF OBJECT_ID('dbo.clientes', 'U') IS NOT NULL DROP TABLE dbo.clientes;
IF OBJECT_ID('dbo.categorias', 'U') IS NOT NULL DROP TABLE dbo.categorias;
GO

-- Seccion 2: Create Tables
-- Orden de creacion: primero dimension, luego la de hechos

-- Tabla 1: Categorias

CREATE TABLE categorias (
    id_categoria INT PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200)
);

-- Tabla 2: Clientes

CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    ciudad VARCHAR(50),
    fecha_registro DATE NOT NULL
);

-- Tabla 3: Productos

CREATE TABLE productos (
    id_producto INT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    id_categoria INT,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    activo BIT DEFAULT 1,

    CONSTRAINT fk_productos_categorias
        FOREIGN KEY (id_categoria)
        REFERENCES categorias (id_categoria)
);

-- Tabla 4: Ventas

CREATE TABLE ventas (
    id_venta INT PRIMARY KEY,
    id_cliente INT,
    id_producto INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    fecha_venta DATE NOT NULL,

    CONSTRAINT fk_ventas_clientes
        FOREIGN KEY (id_cliente)
        REFERENCES clientes (id_cliente),
    CONSTRAINT fk_ventas_productos
        FOREIGN KEY (id_producto)
        REFERENCES productos (id_producto)
);
GO

-- Seccion 3: Insert Data
-- Insertando registros primero en tablas sin dependencias 

-- Insertar registros en Categorias

INSERT INTO categorias (id_categoria,nombre_categoria,descripcion)
VALUES
(1,'Computación','Laptops, PCs y monitores'),
(2,'Accesorios','Periféricos y complementos'),
(3,'Audio','Auriculares y parlantes'),
(4,'Almacenamiento','Discos y memorias');

-- Insertar registros en Clientes

INSERT INTO clientes (id_cliente,nombre,email,ciudad,fecha_registro)
VALUES
(1, 'María López', 'maria@mail.com', 'Buenos Aires', '2024-01-05'),
(2, 'Carlos Ruiz', 'carlos@mail.com', 'Córdoba', '2024-01-10'),
(3, 'Ana Gómez', 'ana@mail.com', 'Rosario', '2024-02-01'),
(4, 'Pedro Sanz', 'pedro@mail.com', 'Mendoza', '2024-02-15'),
(5, 'Laura Torres', 'laura@mail.com', 'Tucumán', '2024-03-01');

-- Insertar registros en Productos

INSERT INTO productos (id_producto,nombre_producto,id_categoria,precio,stock,activo)
VALUES
(1, 'Laptop Pro 15', 1, 1200.00, 15, 1),
(2, 'Mouse Inalámbrico', 2, 28.00, 80, 1),
(3, 'Monitor 4K 27', 1, 450.00, 12, 1),
(4, 'Auriculares BT Pro', 3, 120.00, 35, 1),
(5, 'SSD Externo 1TB', 4, 130.00, 18, 1),
(6, 'Teclado Mecánico', 2, 95.00, 40, 1);

-- Insertar registros en Ventas

INSERT INTO ventas (id_venta,id_cliente,id_producto,cantidad,precio_unitario,fecha_venta)
VALUES
(1, 1, 1, 2, 1200.00, '2024-03-05'),
(2, 2, 2, 5, 28.00, '2024-03-06'),
(3, 3, 3, 1, 450.00, '2024-03-07'),
(4, 1, 4, 2, 120.00, '2024-03-08'),
(5, 4, 5, 3, 130.00, '2024-03-10'),
(6, 2, 6, 4, 95.00, '2024-03-11'),
(7, 5, 1, 1, 1200.00, '2024-03-12'),
(8, 3, 2, 8, 28.00, '2024-03-13'),
(9, 4, 4, 1, 120.00, '2024-03-14'),
(10, 5, 3, 2, 450.00, '2024-03-15');
GO

-- Seccion 4: Validacion
-- Comprobacion de filas cargadas

SELECT * FROM categorias; -- Esperado: 4 filas
SELECT * FROM clientes;   -- Esperado: 5 filas
SELECT * FROM productos;  -- Esperado: 6 filas
SELECT * FROM ventas;     -- Esperado: 10 filas
GO


-- =========================================================
-- PROYECTO: Ventas_Tech_DB
-- ARCHIVO: m4_consultas_negocio.sql
-- DESCRIPCIÓN: Consultas analíticas de negocio (Pre-entrega M4)
-- =========================================================

USE Ventas_Tech_DB;
GO

-- =========================================================
-- CONSULTA 1: Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio, agrupados por mes.
-- =========================================================

SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    ROUND(AVG(cantidad * precio_unitario), 2) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes ASC;
GO

-- =========================================================
-- CONSULTA 2: Ranking de productos (Top 5 de id_producto por total facturado)
-- Muestra el top 5 de productos por facturación y sus unidades vendidas.
-- =========================================================

SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;
GO

-- =========================================================
-- CONSULTA 3: Clientes recurrentes
-- Clientes con más de 1 pedido, indicando compras y gasto total.
-- =========================================================

SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
GO

-- =========================================================
-- CONSULTA 4: Meses por encima / por debajo del promedio general
-- Evalúa el rendimiento mensual frente a la media general de facturación.
-- =========================================================

WITH FacturacionMensual AS (
    SELECT 
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT 
    mes,
    total_facturado,
    CASE 
        WHEN total_facturado >= (SELECT AVG(total_facturado) FROM FacturacionMensual) 
        THEN 'Por encima'
        ELSE 'Por debajo'
    END AS rendimiento_respecto_al_promedio
FROM FacturacionMensual
ORDER BY mes ASC;
GO

/*
=========================================================
BLOQUE DE CIERRE: HALLAZGOS DE NEGOCIO
=========================================================
1. Concentración en Producto Estrella: El id_producto = 1 (Laptop Pro 15) 
   es el mayor generador de ingresos de la empresa ($3,600.00 sobre las ventas totalizadas), 
   siendo el pilar principal de la facturación en el periodo analizado.

2. Identificación de Clientes Clave: El cliente id_cliente = 1 destaca como el comprador 
   más valioso, habiendo registrado 2 pedidos por un acumulado total de $2,640.00, 
   seguido por el id_cliente = 5 con $2,100.00.

3. Estructura Temporal de Ventas: Toda la actividad comercial registrada se concentra en el 
   mes de Marzo (Mes 3). La primera quincena de ese mes concentró las transacciones de mayor 
   volumen e importe debido a la demanda de equipos de computación.
=========================================================
*/

