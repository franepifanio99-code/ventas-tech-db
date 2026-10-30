# Ventas_Tech_DB - Proyecto Analítico RetailPro

Este repositorio contiene el proyecto analítico de extremo a extremo para la distribuidora tecnológica **RetailPro**. El proyecto abarca desde el modelado relacional en SQL Server hasta la ingesta de datos, creación de un modelo dimensional en estrella en Power BI, definición de métricas avanzadas en DAX y diseño de tableros ejecutivos.

---

## 🛠️ Herramientas Utilizadas
* **SQL Server**: Diseño del modelo relacional, creación de vistas y scripts de análisis exploratorio.
* **Power Query**: Limpieza, transformación e ingesta de datos.
* **Power BI**: Modelado dimensional en estrella, fórmulas DAX (inteligencia de tiempo) y diseño de dashboards bajo patrón Z.
* **GitHub**: Control de versiones y documentación.

---

## 🗂️ Estructura del Repositorio

* `/scripts_sql/`: Scripts de creación de base de datos (`Ventas_Tech_DB`), tablas y consultas analíticas.
* `/power_bi/`: Archivo `.pbix` con el modelo relacional, medidas DAX y tableros.
* `/entregables_pdf/`: Documentación y reportes en PDF de cada hito (M6, M7, M8, M9).

---

## 🚀 Instrucciones de Ejecución de Scripts SQL

Para reconstruir la base de datos sin errores de claves foráneas, ejecute los scripts en SQL Server en el siguiente orden estricto de dependencias:

1. **Creación de Tablas Dimensión (Sin dependencias):**
   * `Dim_Clientes`
   * `Dim_Categorias`
2. **Creación de Tablas de Nivel Intermedio:**
   * `Dim_Productos` (Relacionada con `Dim_Categorias`)
3. **Creación de la Tabla de Hechos:**
   * `Fact_Ventas` (Relacionada con `Dim_Clientes` y `Dim_Productos`)
4. **Carga de Datos e Ingesta.**

---

## 📊 Arquitectura del Modelo de Datos

El reporte en Power BI implementa un **Esquema en Estrella** conectando:
* `Fact_Ventas` (Hechos)
* `Dim_Clientes`, `Dim_Productos`, `Dim_Categorias` y `Dim_Fechas` (Dimensiones)

---
*Proyecto académico desarrollado para la certificación de Data Analytics.*
