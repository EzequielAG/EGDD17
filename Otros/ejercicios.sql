-- 1. Mostrar el c�digo, raz�n social de todos los clientes cuyo l�mite de cr�dito sea mayor o igual a $ 1000
-- ordenado por c�digo de cliente.

SELECT
	clie_codigo CODIGO,
	clie_razon_social 'RAZON SOCIAL'
	
	FROM Cliente

	WHERE clie_limite_credito >= 1000

	ORDER BY clie_codigo

-- 2. Mostrar el c�digo, detalle de todos los art�culos vendidos en el a�o 2012 ordenados por cantidad vendida.

SELECT 
	prod_codigo AS CODIGO,
	prod_detalle AS DETALLE

	FROM Factura
	LEFT JOIN Item_Factura ON fact_numero = item_numero
	LEFT JOIN Producto ON item_producto = prod_codigo

	WHERE YEAR(fact_fecha) = 2012

	ORDER BY item_cantidad ASC

-- 3. Realizar una consulta que muestre c�digo de producto, nombre de producto y el stock total, sin importar
-- en que deposito se encuentre, los datos deben ser ordenados por nombre del art�culo de menor a mayor.

SELECT
	prod_codigo 'CODIGO DE PRODUCTO',
	prod_detalle 'DETALLE DE PRODUCTO',
	SUM(stoc_cantidad) 'STOCK TOTAL'

	FROM Producto
	INNER JOIN STOCK ON prod_codigo = stoc_producto

	GROUP BY prod_codigo, prod_detalle

	ORDER BY prod_detalle ASC

-- 4. Realizar una consulta que muestre para todos los art�culos c�digo, detalle y cantidad de art�culos que lo
-- componen. Mostrar solo aquellos art�culos para los cuales el stock promedio por dep�sito sea mayor a 100.
-- comp_producto -> codigo_de_la_composicion comp_componente -> producto_que_la_compone

SELECT
	prod_codigo CODIGO,
	prod_detalle DETALLE,
	COUNT( comp_producto ) CANTIDAD
	
	FROM Composicion
	LEFT JOIN Producto ON comp_componente = prod_codigo

	WHERE (SELECT AVG(stoc_cantidad) 
				FROM STOCK 
				WHERE stoc_producto = prod_codigo 
				GROUP BY stoc_producto) > 100
	
	GROUP BY comp_componente, prod_codigo, prod_detalle

SELECT *
	FROM Composicion
	LEFT JOIN Producto ON comp_componente = prod_codigo
	LEFT JOIN STOCK ON prod_codigo = stoc_producto

SELECT
	stoc_producto PRODUCTO,
	AVG(stoc_cantidad) 'CANTIDAD PROMEDIO'
	FROM STOCK
	GROUP BY stoc_producto
	ORDER BY stoc_producto ASC

-- 5. Realizar una consulta que muestre c�digo de art�culo, detalle y cantidad de egresos de stock que se
-- realizaron para ese art�culo en el a�o 2012 (egresan los productos que fueron vendidos). 
-- Mostrar solo aquellos que hayan tenido m�s egresos que en el 2011.

SELECT
	prod_codigo CODIGO,
	prod_detalle DETALLE,
	SUM(IDOCE.item_cantidad) CANTIDAD
	
	FROM Factura FDOCE
	LEFT JOIN Item_Factura IDOCE ON FDOCE.fact_numero = IDOCE.item_numero
	LEFT JOIN Producto ON IDOCE.item_producto = prod_codigo

	WHERE YEAR(FDOCE.fact_fecha) = 2012
	
	GROUP BY prod_codigo, prod_detalle

	HAVING SUM(IDOCE.item_cantidad) > (
		SELECT SUM(IONCE.item_cantidad)
			FROM Factura FONCE
			LEFT JOIN Item_Factura IONCE ON FONCE.fact_numero = IONCE.item_numero

			WHERE YEAR(FONCE.fact_fecha) = 2011
				AND IONCE.item_producto = prod_codigo)

	ORDER BY prod_codigo ASC

SELECT SUM(IONCE.item_cantidad)
	
	FROM Factura FONCE
	LEFT JOIN Item_Factura IONCE ON FONCE.fact_numero = IONCE.item_numero

	WHERE YEAR(FONCE.fact_fecha) = 2012
		AND IONCE.item_producto = '00000102'

SELECT *
	FROM Factura FDOCE
	LEFT JOIN Item_Factura IDOCE ON FDOCE.fact_numero = IDOCE.item_numero
	LEFT JOIN Producto ON IDOCE.item_producto = prod_codigo

	WHERE YEAR(FDOCE.fact_fecha) = 2011

-- 6. Mostrar para todos los rubros de art�culos c�digo, detalle, cantidad de art�culos de ese rubro y stock
-- total de ese rubro de art�culos. Solo tener en cuenta aquellos art�culos que tengan un stock mayor al del
-- art�culo �00000000� en el dep�sito �00�.

-- ----------- V E R -----------
SELECT
	rubr_id CODIGO,
	rubr_detalle DETALLE,
	COUNT(prod_codigo) CANTIDAD,
	(SELECT SUM(stoc_cantidad)
		FROM STOCK
		LEFT JOIN Producto ON stoc_producto = prod_codigo
		WHERE prod_rubro = rubr_id
		GROUP BY prod_rubro) STOCK
	FROM Producto
	LEFT JOIN Rubro ON prod_rubro = rubr_id
	GROUP BY rubr_id, rubr_detalle
	HAVING (SELECT SSTOCK.stoc_cantidad
				FROM STOCK SSTOCK
				WHERE SSTOCK.stoc_producto = '00000000'
					AND SSTOCK.stoc_deposito = 00) 
			< (SELECT SUM(stoc_cantidad)
					FROM STOCK PSTOCK
					WHERE PSTOCK.stoc_producto = prod_codigo)

SELECT
	SUM(stoc_cantidad)
	FROM STOCK
	LEFT JOIN Producto ON stoc_producto = prod_codigo
	GROUP BY prod_rubro

-- 7. Generar una consulta que muestre para cada articulo c�digo, detalle, mayor precio menor precio y % de
-- la diferencia de precios (respecto del menor Ej.: menor precio = 10, mayor precio =12 => mostrar 20 %).
-- Mostrar solo aquellos art�culos que posean stock.


SELECT
	prod_codigo CODIGO,
	prod_detalle DETALLE,
	MAX(item_precio) MAXIMO,
	MIN(item_precio) MINIMO,
	((MAX(item_precio) - MIN(item_precio))*100/MIN(item_precio))
	FROM Item_Factura
	LEFT JOIN Producto ON item_producto = prod_codigo
	LEFT JOIN STOCK ON prod_codigo = stoc_producto
	WHERE stoc_cantidad > 0
	GROUP BY prod_codigo, prod_detalle
	ORDER BY CODIGO

-- 8. Mostrar para el o los art�culos que tengan stock en todos los dep�sitos, nombre del art�culo, stock del
-- dep�sito que m�s stock tiene.

SELECT Producto.prod_codigo, Producto.prod_detalle, MAX(STOCK.stoc_cantidad)
	FROM Producto
		INNER JOIN STOCK ON Producto.prod_codigo = STOCK.stoc_producto
	GROUP BY Producto.prod_codigo, STOCK.stoc_producto, Producto.prod_detalle
	HAVING COUNT(DISTINCT(STOCK.stoc_deposito)) = (SELECT COUNT(DISTINCT(DEPOSITO.depo_codigo)) FROM DEPOSITO)

-- 9. Mostrar el c�digo del jefe, c�digo del empleado que lo tiene como jefe, nombre del mismo y la cantidad de 
-- dep�sitos que ambos tienen asignados.

SELECT empl_jefe, empl_codigo, empl_nombre, COUNT(depo_codigo)
	FROM Empleado
		INNER JOIN DEPOSITO ON empl_codigo = depo_encargado
	GROUP BY depo_encargado, empl_jefe, empl_codigo, empl_nombre

-- 10. Mostrar los 10 productos mas vendidos en la historia y tambi�n los 10 productos menos vendidos en 
-- la historia. Adem�s mostrar de esos productos, quien fue el cliente que mayor compra realizo.

-- ----------- X   E L   P R O F E -----------
SELECT 
	prod_codigo, 
	prod_detalle,
	(SELECT TOP 1 fact_cliente
		FROM Factura, Item_Factura
		WHERE fact_numero = item_numero AND
			fact_sucursal = item_sucursal AND
			item_producto = prod_codigo)
	FROM Producto
	WHERE prod_codigo IN (
			SELECT TOP 10 item_producto
			FROM Item_Factura
			GROUP BY item_producto
			ORDER BY SUM(item_cantidad) DESC) OR
		prod_codigo IN (
			SELECT TOP 10 item_producto
			FROM Item_Factura
			GROUP BY item_producto
			ORDER BY SUM(item_cantidad) ASC)

-- 11. Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de productos vendidos
-- y el monto de dichas ventas sin impuestos. Los datos se deber�n ordenar de mayor a menor, por la familia 
-- que m�s productos diferentes vendidos tenga, solo se deber�n mostrar las familias que tengan una venta superior 
-- a 20000 pesos para el a�o 2012.

SELECT 
	fami_detalle,
	COUNT(DISTINCT item_producto) CANTIDAD,
	SUM((item_cantidad * item_precio)/1.21)
FROM Familia F1
INNER JOIN Producto P1 ON F1.fami_id = P1.prod_familia
INNER JOIN Item_Factura IF1 ON P1.prod_codigo = IF1.item_producto
GROUP BY F1.fami_id, F1.fami_detalle
HAVING F1.fami_id IN (
	SELECT P2.prod_familia
		FROM Producto P2
		INNER JOIN Item_Factura IF2 ON P2.prod_codigo = IF2.item_producto
		INNER JOIN Factura F2 ON IF2.item_numero = F2.fact_numero
		WHERE YEAR(F2.fact_fecha) = '2012'
		GROUP BY P2.prod_familia
		HAVING SUM(IF2.item_cantidad * IF2.item_precio) > 2000)
ORDER BY CANTIDAD DESC

-- 12. Mostrar nombre de producto, cantidad de clientes distintos que lo compraron, importe promedio pagado
-- por el producto, cantidad de dep�sitos en lo cuales hay stock del producto y stock actual del producto
-- en todos los dep�sitos. Se deber�n mostrar aquellos productos que hayan tenido operaciones en el a�o 2012
-- y los datos deber�n ordenarse de mayor a menor por monto vendido del producto.

SELECT 
	prod_codigo,
	prod_detalle,
	(SELECT COUNT(DISTINCT(fact_cliente))
	 FROM Factura
	 INNER JOIN Item_Factura ON fact_numero = item_numero
	 WHERE item_producto = prod_codigo) AS CANT_CLIENTES,
	(SELECT AVG(item_precio)
	 FROM Item_Factura
	 WHERE item_producto = prod_codigo) AS PROMEDIO_PAGADO,
	(SELECT COUNT(DISTINCT(stoc_deposito))
	 FROM STOCK
	 WHERE stoc_producto = prod_codigo) AS CANT_DEPO,
	(SELECT SUM(stoc_cantidad)
	 FROM STOCK
	 WHERE stoc_producto = prod_codigo) AS CANT_ACTUAL
FROM Producto
GROUP BY prod_codigo, prod_detalle
HAVING prod_codigo IN (SELECT item_producto
					   FROM Item_Factura
					   INNER JOIN Factura ON item_numero = fact_numero
					   WHERE YEAR(fact_fecha) = 2012)
ORDER BY (SELECT SUM(item_cantidad)
		  FROM Item_Factura
		  WHERE item_producto = prod_codigo) DESC

-- 13. Realizar una consulta que retorne para cada producto que posea composici�n nombre del producto,
-- precio del producto, precio de la sumatoria de los precios por la cantidad de los productos que lo componen.
-- Solo se deber�n mostrar los productos que est�n compuestos por m�s de 2 productos y deben ser ordenados de
-- mayor a menor por cantidad de productos que lo componen.

-- 14. Escriba una consulta que retorne una estad�stica de ventas por cliente. Los campos que debe retornar son:
--		C�digo del cliente
--		Cantidad de veces que compro en el �ltimo a�o
--		Promedio por compra en el �ltimo a�o
--		Cantidad de productos diferentes que compro en el �ltimo a�o
--		Monto de la mayor compra que realizo en el �ltimo a�o
-- Se deber�n retornar todos los clientes ordenados por la cantidad de veces que compro en el �ltimo a�o.
-- No se deber�n visualizar NULLs en ninguna columna

-- 15. Escriba una consulta que retorne los pares de productos que hayan sido vendidos juntos (en la misma factura)
-- m�s de 500 veces. El resultado debe mostrar el c�digo y descripci�n de cada uno de los productos y la cantidad
-- de veces que fueron vendidos juntos. El resultado debe estar ordenado por la cantidad de veces que se vendieron
-- juntos dichos productos. Los distintos pares no deben retornarse m�s de una vez.
-- Ejemplo de lo que retornar�a la consulta:
--		PROD1  DETALLE1          PROD2  DETALLE2               VECES
--		1731   MARLBORO KS       1718   PHILIPS MORRIS KS      507
--		1718   PHILIPS MORRIS KS 1705   PHILIPS MORRIS BOX 10  562

SELECT item_numero, COUNT(item_producto) 
FROM Item_Factura
GROUP BY item_numero

SELECT prod_codigo, COUNT(item_numero) AS CANTIDAD
FROM Producto
INNER JOIN Item_Factura ON prod_codigo = item_producto
GROUP BY prod_codigo
ORDER BY CANTIDAD DESC


-- 16. Con el fin de lanzar una nueva campa�a comercial para los clientes que menos compran en la empresa,
-- se pide una consulta SQL que retorne aquellos clientes cuyas ventas son inferiores a 1/3 del promedio de ventas
-- del/los producto/s que m�s se vendieron en el 2012. Adem�s mostrar:
--		1. Nombre del Cliente
--		2. Cantidad de unidades totales vendidas en el 2012 para ese cliente.
--		3. C�digo de producto que mayor venta tuvo en el 2012 (en caso de existir m�s de 1, mostrar solamente el
--			 de menor c�digo) para ese cliente.
-- Aclaraciones:
--		La composici�n es de 2 niveles, es decir, un producto compuesto solo se compone de productos no compuestos.
--		Los clientes deben ser ordenados por c�digo de provincia ascendente.

-- 17. Escriba una consulta que retorne una estad�stica de ventas por a�o y mes para cada producto.
-- La consulta debe retornar:
--		PERIODO: A�o y mes de la estad�stica con el formato YYYYMM
--		PROD: C�digo de producto
--		DETALLE: Detalle del producto
--		CANTIDAD_VENDIDA= Cantidad vendida del producto en el periodo
--		VENTAS_A�O_ANT= Cantidad vendida del producto en el mismo mes del periodo pero del a�o anterior
--		CANT_FACTURAS= Cantidad de facturas en las que se vendi� el producto en el 	periodo
-- La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada por periodo y c�digo de producto.

-- 18. Escriba una consulta que retorne una estad�stica de ventas para todos los rubros. La consulta debe retornar:
--		DETALLE_RUBRO: Detalle del rubro
--		VENTAS: Suma de las ventas en pesos de productos vendidos de dicho rubro
--		PROD1: C�digo del producto m�s vendido de dicho rubro
--		PROD2: C�digo del segundo producto m�s vendido de dicho rubro
--		CLIENTE: C�digo del cliente que compro m�s productos del rubro en los �ltimos 30 d�as
-- La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada por cantidad de
-- productos diferentes vendidos del rubro