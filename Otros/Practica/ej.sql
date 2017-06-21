 -- Ejercicio 3 --
USE [GD2015C1]
GO
SELECT p.prod_codigo, p.prod_detalle as 'nombre', 
    CASE WHEN EXISTS(SELECT 1 FROM Composicion c WHERE c.comp_producto = p.prod_codigo) 
        THEN 'Compuesto'
         ELSE 'Simple' 
    END AS 'Composicion',
    'Producto exitoso' AS 'Leyenda'
    FROM Producto p
    WHERE p.prod_codigo IN(SELECT TOP 3 i2.item_producto
                                FROM Item_Factura i2
                                INNER JOIN Factura f2 ON i2.item_numero = f2.fact_numero AND
                                                     i2.item_tipo = f2.fact_tipo AND i2.item_sucursal = f2.fact_sucursal
                                WHERE YEAR(f2.fact_fecha) = 2015
                                GROUP BY i2.item_producto
                                HAVING (SELECT ISNULL(SUM(i3.item_cantidad),0) FROM Item_Factura i3
                                            INNER JOIN Factura f3 ON f3.fact_numero = i3.item_numero AND f3.fact_tipo = i3.item_tipo
                                                                     AND f3.fact_sucursal = i3.item_sucursal
                                            WHERE i3.item_producto = i2.item_producto AND YEAR(f3.fact_fecha) = 2010) > 5
                                ORDER BY SUM(f2.fact_total) DESC)
    GROUP BY p.prod_codigo, p.prod_detalle
UNION ALL
SELECT p.prod_codigo, p.prod_detalle as 'nombre', 
    CASE WHEN EXISTS(SELECT 1 FROM Composicion c WHERE c.comp_producto = p.prod_codigo) 
        THEN 'Compuesto'
         ELSE 'Simple' 
    END AS 'Composicion',
    'Producto a evaluar' as 'Leyenda'
    FROM Producto p
    WHERE p.prod_codigo IN(SELECT TOP 3 i2.item_producto
                                FROM Item_Factura i2
                                INNER JOIN Factura f2 ON i2.item_numero = f2.fact_numero AND
                                                     i2.item_tipo = f2.fact_tipo AND i2.item_sucursal = f2.fact_sucursal
                                WHERE YEAR(f2.fact_fecha) = 2015
                                GROUP BY i2.item_producto
                                HAVING (SELECT ISNULL(SUM(i3.item_cantidad),0) FROM Item_Factura i3
                                            INNER JOIN Factura f3 ON f3.fact_numero = i3.item_numero AND f3.fact_tipo = i3.item_tipo
                                                                     AND f3.fact_sucursal = i3.item_sucursal
                                            WHERE i3.item_producto = i2.item_producto AND YEAR(f3.fact_fecha) = 2010) > 5
                                ORDER BY SUM(f2.fact_total) ASC)
    GROUP BY p.prod_codigo, p.prod_detalle

 -- Ejercicio 4 --
USE [GD2015C1]
GO
CREATE TRIGGER tcontrolarcargacomision ON Empleado
    FOR INSERT, UPDATE
AS
BEGIN TRANSACTION
    UPDATE empleado SET empl_comision = 5
        WHERE EXISTS(SELECT 1 FROM Inserted 
                        WHERE empl_codigo = empleado.empl_codigo
                            and (SELECT COUNT(*) FROM DEPOSITO WHERE depo_encargado = empl_codigo) < 4
                            and Empleado.empl_comision > 5)
COMMIT TRANSACTION