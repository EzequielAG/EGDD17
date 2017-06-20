-- Practica nro 2 --- ej dos --

SELECT DS.depo_codigo, COUNT(E.empl_codigo) CANT_EMP, AVG(YEAR(GETDATE()) - YEAR(E.empl_nacimiento)) EDAD_PROM
	FROM DEPOSITO DS
		LEFT JOIN Zona Z ON DS.depo_zona = Z.zona_codigo
		LEFT JOIN Departamento DT ON Z.zona_codigo = DT.depa_zona
		LEFT JOIN Empleado E ON DT.depa_codigo = E.empl_departamento OR
			DS.depo_encargado = E.empl_codigo
	GROUP BY DS.depo_codigo
