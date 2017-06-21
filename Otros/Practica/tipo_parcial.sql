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

-- Practica nro 2 --- ej uno --

SELECT 
	DS.depo_codigo, 
	COUNT(E.empl_codigo) CANT_EMP, 
	AVG(YEAR(GETDATE()) - YEAR(E.empl_nacimiento)) EDAD_PROM,
	(SELECT TOP 1 CONCAT(E2.empl_apellido, E2.empl_nombre)
		FROM Empleado E2
			INNER JOIN Departamento DT2 ON E2.empl_departamento = DT2.depa_codigo
			INNER JOIN Zona Z2 ON DT2.depa_zona = Z2.zona_codigo
			INNER JOIN DEPOSITO DS2 ON Z2.zona_codigo = DS2.depo_zona OR
				E2.empl_codigo = DS2.depo_encargado
		WHERE DS2.depo_codigo = DS.depo_codigo
		ORDER BY E2.empl_nacimiento ASC) AS EMPLEADO,
	(SELECT CASE WHEN(
		SELECT TOP 1 E3.empl_codigo
			FROM Empleado E3
				INNER JOIN Departamento DT3 ON E3.empl_departamento = DT3.depa_codigo
				INNER JOIN Zona Z3 ON DT3.depa_zona = Z3.zona_codigo
				INNER JOIN DEPOSITO DS3 ON Z3.zona_codigo = DS3.depo_zona OR
					E3.empl_codigo = DS3.depo_encargado
			WHERE DS3.depo_codigo = DS.depo_codigo
			ORDER BY E3.empl_nacimiento ASC) = (SELECT D4.depo_encargado 
													FROM DEPOSITO D4
													WHERE D4.depo_codigo = DS.depo_codigo) THEN (SELECT 'ES JEFE')
			ELSE (SELECT 'NO ES JEFE') END) AS JEFE
	FROM DEPOSITO DS
		LEFT JOIN Zona Z ON DS.depo_zona = Z.zona_codigo
		LEFT JOIN Departamento DT ON Z.zona_codigo = DT.depa_zona
		LEFT JOIN Empleado E ON DT.depa_codigo = E.empl_departamento OR
			DS.depo_encargado = E.empl_codigo 
	GROUP BY DS.depo_codigo

--  --


---- NO SALIO

-- Practica 1 -- Ejercicio 1 --

SELECT D.depo_codigo, D.depo_detalle, R.rubr_id, R.rubr_detalle, 
	(SELECT CASE
		WHEN (SELECT COUNT(*)
				FROM (SELECT P1.prod_detalle
						FROM Producto P1
							INNER JOIN Rubro R1 ON P1.prod_rubro = R1.rubr_id
							INNER JOIN Item_Factura I1 ON P1.prod_codigo = I1.item_producto
						WHERE R1.rubr_id = R.rubr_id
						GROUP BY P1.prod_detalle
						HAVING SUM(I1.item_cantidad) = (SELECT TOP 1 SUM(I2.item_cantidad) CANT
															FROM Producto P2
																INNER JOIN Rubro R2 ON P2.prod_rubro = R2.rubr_id
																INNER JOIN Item_Factura I2 ON P2.prod_codigo = I2.item_producto
															WHERE R2.rubr_id = R.rubr_id
															GROUP BY P2.prod_codigo
															ORDER BY CANT DESC)) AS TABLA) = 1 -- OBTENER EL MAXIMO.
			THEN (SELECT TOP 1 P3.prod_detalle
					FROM Producto P3
						INNER JOIN Rubro R3 ON P3.prod_rubro = R3.rubr_id
						INNER JOIN Item_Factura I3 ON P3.prod_codigo = I3.item_producto
					WHERE R3.rubr_id = R.rubr_id
					GROUP BY P3.prod_detalle
					ORDER BY SUM(I3.item_cantidad) DESC)
		ELSE 'MAS DE UNO EXITOSO'
	END)
	FROM DEPOSITO D
		INNER JOIN STOCK S ON D.depo_codigo = S.stoc_deposito
		INNER JOIN Producto P ON S.stoc_producto = P.prod_codigo
		INNER JOIN Rubro R ON P.prod_rubro = R.rubr_id
	GROUP BY D.depo_codigo, D.depo_detalle, R.rubr_id, R.rubr_detalle
	ORDER BY D.depo_codigo