-- Practica nro 1 --- ej dos --

IF OBJECT_ID (N'dbo.calcular_anio_anterior', N'FN') IS NOT NULL  
    DROP FUNCTION calcular_anio_anterior;  
GO  
CREATE FUNCTION dbo.calcular_anio_anterior(@id_vendedor numeric(6), @anio int)  
RETURNS int
AS   
BEGIN
	DECLARE @monto int
	SELECT @monto = (SUM(f.fact_total) * 130)
	FROM Factura f
	WHERE YEAR(f.fact_fecha) = @anio and f.fact_vendedor = @id_vendedor  
	RETURN @monto;  
END;  
GO

SELECT 
	E.empl_codigo
	-- dbo.calcular_anio_anterior(E.empl_codigo, YEAR(F.fact_fecha)) AS CANTIDAD1,
	-- dbo.calcular_anio_anterior(E.empl_codigo, YEAR(F.fact_fecha) - 1) AS CANTIDAD2
	FROM Empleado E
	INNER JOIN Factura F ON E.empl_codigo = F.fact_vendedor

	WHERE dbo.calcular_anio_anterior(E.empl_codigo, YEAR(F.fact_fecha)) >=
			dbo.calcular_anio_anterior(E.empl_codigo, YEAR(F.fact_fecha) - 1)

	GROUP BY E.empl_codigo

-- Practica nro 2 --- ej dos --

SELECT DS.depo_codigo, COUNT(E.empl_codigo) CANT_EMP, AVG(YEAR(GETDATE()) - YEAR(E.empl_nacimiento)) EDAD_PROM
	FROM DEPOSITO DS
		LEFT JOIN Zona Z ON DS.depo_zona = Z.zona_codigo
		LEFT JOIN Departamento DT ON Z.zona_codigo = DT.depa_zona
		LEFT JOIN Empleado E ON DT.depa_codigo = E.empl_departamento OR
			DS.depo_encargado = E.empl_codigo
	GROUP BY DS.depo_codigo
