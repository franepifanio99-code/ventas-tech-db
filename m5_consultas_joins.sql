-- =========================================================
-- PROYECTO: Ventas_Tech_DB
-- ARCHIVO: m5_consultas_joins.sql
-- DESCRIPCIÓN: Consultas cruzadas con JOINs y UNION ALL (Pre-entrega M5)
-- =========================================================

USE Ventas_Tech_DB;
GO

-- =========================================================
-- CONSULTA 1: Vista base del proyecto (INNER JOIN)
-- Vista unificada de ventas enriquecida con datos de clientes,
-- productos y categorías (Base principal para Power BI).
-- =========================================================

SELECT 
    v.fecha_venta,
    v.id_cliente,
    c.nombre AS nombre_cliente,
    c.ciudad AS region_cliente,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas v
INNER JOIN clientes c 
    ON v.id_cliente = c.id_cliente
INNER JOIN productos p 
    ON v.id_producto = p.id_producto
INNER JOIN categorias cat 
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta ASC;

-- Usamos INNER JOIN para relacionar la tabla de hechos (ventas) con las de dimensiones (clientes,productos, categorias).
-- Los campos obligatorios son "fecha, id cliente, descripcion producto, cantidad, precio unitario y total venta".
-- De nuestro esquema agregamos "nombre cliente, ciudad cliente, categoria del producto". Sumamos "ciudad y categoria
-- del producto" para luego poder filtrar por ellas en Power BI.

-- =========================================================
-- CONSULTA 2: Clientes sin ventas (LEFT JOIN)
-- Identifica los clientes registrados que aún no han realizado compras.
-- =========================================================

SELECT 
    c.nombre AS nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v 
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
GO

-- =========================================================
-- CONSULTA 3: Productos sin ventas (LEFT JOIN)
-- Identifica productos del catálogo sin ventas registradas.
-- =========================================================

SELECT 
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat 
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v 
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;
GO

-- =========================================================
-- CONSULTA 4: Consolidado por canal (UNION ALL)
-- Asigna un canal según rango de fechas (Online vs Presencial),
-- une los conjuntos con UNION ALL y consolida la facturación total.
-- =========================================================

SELECT 
    canal,
    SUM(total) AS total_canal
FROM (
    SELECT 
        fecha_venta, 
        cantidad * precio_unitario AS total, 
        'Online' AS canal
    FROM ventas 
    WHERE fecha_venta <= '2024-03-10'
    UNION ALL
    SELECT 
        fecha_venta, 
        cantidad * precio_unitario AS total, 
        'Presencial' AS canal
    FROM ventas 
    WHERE fecha_venta > '2024-03-10'
) AS consolidado
GROUP BY canal;
GO

-- Tenés que dividir tus ventas en dos grupos usando un filtro WHERE. 
-- En nuestro caso, dividimos las ventas por rango de fechas: Un SELECT para antes del 10 de marzo y otro Select
-- posterior al 10 de marzo.
-- ") AS consolidado": Le ponemos un alias a esa tabla temporal unificada para que la consulta externa pueda leerla.
-- SELECT canal, SUM(total) AS total_canal: Toma los nombres de canal y suma todo el dinero generado por cada uno.