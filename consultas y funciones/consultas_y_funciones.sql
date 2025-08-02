USE desarrollos_inmobiliarios_db;

/*
**************************
*       CONSULTA 1       *
**************************
*/

/*Obtener la cantidad total de propiedades que se tienen registradas por desarrollo,
así como la cantidad de propiedades que se han logrado vender y/o rentar por desarrollo, 
y la proporción entre las propiedades vendidas y/o rentadas y el total de propiedades.

Esta consulta nos permite visualizar que desarrollos han logrado completar el objetivo
de comercializar todas sus propiedades, cuáles están cerca de lograrlo, y
cuáles desarrollos siguen en el proceso de comercialización.*/

SELECT *,
CONCAT(ROUND(propiedades_vendidas_rentadas/propiedades_totales*100,2),'%') AS avance_comercial
FROM(
    SELECT d.id_desarrollo,d.nombre,
          (SELECT COUNT(*) 
            FROM propiedades p 
            WHERE p.id_desarrollo = d.id_desarrollo
          ) AS propiedades_totales,
          (SELECT COUNT(*) 
            FROM propiedades p 
            WHERE p.id_desarrollo = d.id_desarrollo 
            AND p.estado IN ('Vendida', 'Rentada')
          ) AS propiedades_vendidas_rentadas
    FROM desarrollos d
    ) AS R
ORDER BY propiedades_vendidas_rentadas/propiedades_totales*100 DESC,
         propiedades_totales DESC;

/*
**************************
*       CONSULTA 2       *
**************************
*/

/*Obtener un resumen de todos los agentes y la cantidad de contratos que han cerrado,
así como la cantidad total de ingresos que han generado dichos contratos a la empresa.

Esta consulta nos permite visualizar cuales son los agentes que han tenido una mayor 
participación en la comercialización en las propiedades, es decir, aquellos agentes
que han tenido mayor rendimiento respecto al cierre de contratos. Con esta información,
la empresa podría recomendar a los agentes más eficientes para futuros cierres de contratos 
importantes.*/

SELECT a.id_agente,
       CONCAT_WS(' ',a.nombre,a.apellido_paterno,a.apellido_materno) AS nombre_completo_agente,
       COUNT(c.id_propiedad) AS contratos_firmados,
       CONCAT('$ ',FORMAT(SUM(c.precio_final),2)) AS ingresos_totales_generados
FROM contratos c 
RIGHT JOIN agentes a ON c.id_agente = a.id_agente
GROUP BY a.id_agente
ORDER BY SUM(precio_final) DESC;

/*
**************************
*       CONSULTA 3       *
**************************
*/

/*Mostrar a los clientes que han firmado al menos un contrato y cuántos contratos han firmado, 
así como el número total de interacciones que tuvieron esos clientes con los agentes, y el promedio
de interacciones por contrato firmado.

Esta consulta ayuda a encontrar los clientes más relevantes que tiene la empresa, 
así como que tanto necesitan los agentes interactuar con cada uno de ellos para conseguir
que firmen un contrato, es decir, si son fáciles de convencer o no. De este modo, la empresa
puede recomendar otras propiedades a clientes frecuentes o a aquellos que son fáciles de
convencer.*/

SELECT *,ROUND(total_interacciones/contratos_firmados,2) AS interacciones_promedio
FROM(
    SELECT cl.id_cliente,
           CONCAT_WS(' ',cl.nombre,cl.apellido_paterno,cl.apellido_materno) AS nombre_completo_cliente,
          (SELECT COUNT(c.id_contrato)
              FROM contratos c
              WHERE c.id_cliente = cl.id_cliente) 
              AS contratos_firmados,
          (SELECT COUNT(i.num_interaccion)
              FROM interacciones i
              WHERE i.id_cliente = cl.id_cliente) 
              AS total_interacciones
    FROM clientes cl
    ) AS R
WHERE contratos_firmados > 0
ORDER BY interacciones_promedio ASC, contratos_firmados DESC;   

/*
**************************
*       CONSULTA 4       *
**************************
*/

/*Mostrar la cantidad de propiedades registradas por estado, así como la cantidad
de propiedades que se han logrado vender o rentar, la proporción entre las propiedades
vendidas y/o rentadas respecto al total de propiedades, y el total de ingresos generados.

Esta consulta permite destacar los estados que han tenido un mayor crecimiento comercial
para la empresa, lo cual puede contribuir a ser más estrategicos respecto a la locación de
sus futuros desarrollos/propiedades.*/

SELECT *,
CONCAT(ROUND(propiedades_vendidas_rentadas/propiedades_totales*100,2),'%') AS avance_comercial
FROM (
  SELECT e.nombre AS estado,
        COUNT(p.id_propiedad) AS propiedades_totales,
        COUNT(CASE WHEN p.estado IN ('Vendida','Rentada') THEN 1 END) AS propiedades_vendidas_rentadas,
        CONCAT('$ ',FORMAT(SUM(p.precio),2)) AS ingresos_totales
  FROM estados e
  JOIN municipios m ON m.clave_estado = e.clave_estado
  JOIN colonias c ON c.clave_municipio = m.clave_municipio
  JOIN direcciones d ON d.id_colonia = c.id_colonia
  LEFT JOIN propiedades p ON p.id_direccion = d.id_direccion
  GROUP BY e.nombre
  ORDER BY SUM(p.precio) DESC
) AS R;

/*
**************************
*       CONSULTA 5       *
**************************
*/

/*Mostrar un resumen por tipo de desarrollo y por tipo de propiedad que
detalle las propiedades totales, las propiedades vendidas y rentadas, los 
ingresos generados por ventas y/o rentas, y la proporción entre las propiedades
vendidas y/o rentadas y las propiedades totales.

Esta consulta muestra que tipo de construcciones son las que se han colocado
más eficazmente en el mercado, así como destacar cuales son las que más ingresos
le han generado a la empresa, por lo que la empresa podría tomar en consideración 
llevar a cabo más construcciones de los tipos que están siendo más rentables.*/

SELECT *,
CONCAT(ROUND(propiedades_vendidas_rentadas/propiedades_totales*100,2),'%') AS avance_comercial
FROM(
  SELECT d.tipo AS tipo_desarrollo, p.tipo AS tipo_propiedad,
        COUNT(p.id_propiedad) AS propiedades_totales,
        COUNT(CASE WHEN p.estado IN ('Vendida','Rentada') THEN 1 END) AS propiedades_vendidas_rentadas,
        CONCAT('$ ', FORMAT(SUM(CASE WHEN p.estado IN ('Vendida','Rentada') THEN p.precio ELSE 0 END), 2)) 
        AS ingresos_totales
  FROM desarrollos d
  JOIN propiedades p USING(id_desarrollo)
  GROUP BY tipo_desarrollo,tipo_propiedad
  ORDER BY SUM(p.precio) DESC
  ) AS R;

/*
**************************
*       CONSULTA 6       *
**************************
*/

/*Encontrar a los clientes que todavía no liquidan algunos de sus contratos por completo,
mostrando un resumen del precio final pactado en sus contratos, la cantidad que han pagado
hasta el momento, el porcentaje pagado respecto al valor de la propiedad, así como el 
plazo que han tenido desde que se firmó el contrato.

Esta consulta nos permite identificar aquellos clientes que son responsables en sus pagos
así como los que podrían estar teniendo problemas para el pago de sus propiedades, identificándolos 
principalmente por el tiempo que ha transcurrido desde su firma de contrato y el % de pago que 
han acumulado hasta hoy.*/

SELECT p.id_contrato,
    CONCAT_WS(' ',cl.nombre,cl.apellido_paterno,cl.apellido_materno) AS nombre_completo_cliente,
    CONCAT('$ ',FORMAT((c.precio_final),2)) AS precio_final,
    CONCAT('$ ',FORMAT(SUM(p.monto),2)) AS monto_pagado,
    CONCAT(ROUND(SUM(p.monto)/c.precio_final*100,2),'%') AS porcentaje_pagado,
    CONCAT(TIMESTAMPDIFF(YEAR, c.fecha_contrato, NOW()), ' años ',
           TIMESTAMPDIFF(MONTH, c.fecha_contrato, NOW()) % 12, ' meses ',
           DATEDIFF(NOW(), DATE_ADD(DATE_ADD(c.fecha_contrato, 
              INTERVAL TIMESTAMPDIFF(YEAR, c.fecha_contrato, NOW()) YEAR),
              INTERVAL TIMESTAMPDIFF(MONTH, c.fecha_contrato, NOW()) % 12 MONTH)
          ), ' días') AS tiempo_transcurrido
FROM pagos p 
JOIN contratos c ON p.id_contrato = c.id_contrato
JOIN clientes cl ON c.id_cliente = cl.id_cliente
GROUP BY p.id_contrato
HAVING porcentaje_pagado != '100.00%'
ORDER BY SUM(p.monto)/c.precio_final DESC;

/*
**************************
*       CONSULTA 7       *
**************************
*/

/*¿Cuál es el tiempo minimo,promedio,y maximo (en días), que se tardan en vender
o rentar las propiedades desde que se registran hasta que se firma un contrato, 
agrupadas por tipo de desarrollo y tipo de propiedad?

Esta consulta ayuda a tener en mente un intervalo de tiempo en el cuál las propiedades
de cada tipo suelen venderse y/o rentarse, de modo que puede ser útil para la planeación
de futuras construcciones, ya sea tomando en cuenta aquellas construcciones que tengan 
un tiempo de venta/renta menor, o que tengan un intervalo de tiempo más corto.*/

SELECT d.tipo AS tipo_desarrollo,p.tipo AS tipo_propiedad,
CONCAT(FLOOR((MIN(DATEDIFF(c.fecha_contrato,p.fecha_registro)) % 365)/30), ' meses ',
       ROUND((MIN(DATEDIFF(c.fecha_contrato,p.fecha_registro)) % 365) % 30), ' días') AS tiempo_minimo_venta_renta,
CONCAT(FLOOR(AVG(DATEDIFF(c.fecha_contrato,p.fecha_registro))/365),' años ',
  FLOOR((AVG(DATEDIFF(c.fecha_contrato,p.fecha_registro)) % 365)/30), ' meses ',
  ROUND((AVG(DATEDIFF(c.fecha_contrato,p.fecha_registro)) % 365) % 30), ' días') AS tiempo_promedio_venta_renta,
CONCAT(FLOOR(MAX(DATEDIFF(c.fecha_contrato,p.fecha_registro))/365),' años ',
  FLOOR((MAX(DATEDIFF(c.fecha_contrato,p.fecha_registro)) % 365)/30), ' meses ',
  ROUND((MAX(DATEDIFF(c.fecha_contrato,p.fecha_registro)) % 365) % 30), ' días') AS tiempo_maximo_venta_renta
FROM desarrollos d
JOIN propiedades p USING(id_desarrollo)
JOIN contratos c USING(id_propiedad)
WHERE p.estado IN ('Vendida','Rentada')
GROUP BY tipo_desarrollo,tipo_propiedad
ORDER BY AVG(DATEDIFF(c.fecha_contrato,p.fecha_registro));

/*
**************************
*       CONSULTA 8       *
**************************
*/

/*Obtener los nombres completos de los clientes junto con los nombres completos
del/los agente(s) con el(los) que han interactuado el mayor número de veces, así como
la cantidad de interacciones entre el cliente y el/los agente(s).

Esta consulta nos permite tener un registro de cuales son los agentes con los que más han
interactuado los clientes, y por tanto, con los que seguramente ha desarrollado más confianza
o se sienten más satisfechos, de modo que podamos asignar este o estos agente(s) preferido(s) 
por cliente en futuras ventas.*/

SELECT cl.id_cliente, 
       CONCAT_WS(' ',cl.nombre,cl.apellido_paterno,cl.apellido_materno) AS nombre_completo_cliente,
       a.id_agente, 
       CONCAT_WS(' ',a.nombre,a.apellido_paterno,a.apellido_materno) AS nombre_completo_agente,
       i.num_interaccion as total_interacciones
FROM interacciones i
JOIN clientes cl ON i.id_cliente = cl.id_cliente
JOIN agentes a ON i.id_agente = a.id_agente
WHERE (i.id_cliente, i.num_interaccion) IN (SELECT id_cliente, MAX(num_interaccion)
                                            FROM interacciones
                                            GROUP BY id_cliente)
ORDER BY cl.id_cliente;

/*
**************************
*       CONSULTA 9       *
**************************
*/

/*¿Cuál es el tiempo minimo,promedio y máximo que han tardado todas las propiedades
de la empresa que ya están concluidas en construirse, agrupadas por tipo de desarrollo 
y tipo de propiedad?

Esta consulta permite estimar que tanto se tardan en construir las propiedades de
acuerdo a su tipo, lo cual puede ayudar a definir si este tiempo es competitivo con 
respecto a otras empresas inmobiliarias, así como servir de referencia para estimar 
el plazo de construcción en proyectos futuros.*/

SELECT d.tipo AS tipo_desarrollo,p.tipo AS tipo_propiedad,
CONCAT(FLOOR(MIN(DATEDIFF(p.fecha_registro, d.fecha_inicio))/365),' años ',
  FLOOR((MIN(DATEDIFF(p.fecha_registro, d.fecha_inicio)) % 365)/30), ' meses ',
  ROUND(MIN(DATEDIFF(p.fecha_registro, d.fecha_inicio)) % 30), ' días') AS tiempo_minimo_construccion,
CONCAT(FLOOR(AVG(DATEDIFF(p.fecha_registro, d.fecha_inicio))/365),' años ',
  FLOOR((AVG(DATEDIFF(p.fecha_registro, d.fecha_inicio)) % 365)/30), ' meses ',
  ROUND(AVG(DATEDIFF(p.fecha_registro, d.fecha_inicio)) % 30), ' días') AS tiempo_promedio_construccion,
CONCAT(FLOOR(MAX(DATEDIFF(p.fecha_registro, d.fecha_inicio))/365),' años ',
  FLOOR((MAX(DATEDIFF(p.fecha_registro, d.fecha_inicio)) % 365)/30), ' meses ',
  ROUND(MAX(DATEDIFF(p.fecha_registro, d.fecha_inicio)) % 30), ' días') AS tiempo_maximo_construccion
FROM desarrollos d
JOIN propiedades p ON d.id_desarrollo = p.id_desarrollo
WHERE p.estado != 'En construccion'
GROUP BY tipo_desarrollo,tipo_propiedad
ORDER BY AVG(DATEDIFF(p.fecha_registro, d.fecha_inicio));

/*
**************************
*      CONSULTA 10       *
**************************
*/

/*Dada la consulta anterior, ¿Cuáles son las propiedades que la empresa sigue teniendo 
en construcción y ya han superado el tiempo promedio de construcción correspondiente a 
su tipo de desarrollo y propiedad?

Esta consulta nos permite identificar que propiedades están tardando más de lo esperado,
de modo que se pueda evaluar cuáles son los contratiempos que están teniendo dichas propiedades, 
y por tanto, buscar soluciones para intentar acelerar el proceso de construcción.*/

SELECT p.id_propiedad, d.tipo AS tipo_desarrollo, p.tipo AS tipo_propiedad,
       tiempo_promedio_construccion,
       CONCAT(TIMESTAMPDIFF(YEAR, d.fecha_inicio, NOW()), ' años ',
              TIMESTAMPDIFF(MONTH, d.fecha_inicio, NOW()) % 12, ' meses ',
              DATEDIFF(NOW(), DATE_ADD(DATE_ADD(d.fecha_inicio, 
                  INTERVAL TIMESTAMPDIFF(YEAR, d.fecha_inicio, NOW()) YEAR),
                  INTERVAL TIMESTAMPDIFF(MONTH, d.fecha_inicio, NOW()) % 12 MONTH)
          ), ' días') AS tiempo_construccion_transcurrido
FROM propiedades p
JOIN desarrollos d ON p.id_desarrollo = d.id_desarrollo
JOIN (
    SELECT d.tipo AS tipo_desarrollo, p.tipo AS tipo_propiedad, 
           AVG(DATEDIFF(p.fecha_registro, d.fecha_inicio)) AS tiempo_promedio_dias,
           CONCAT(FLOOR(AVG(DATEDIFF(p.fecha_registro, d.fecha_inicio))/365),' años ',
              FLOOR((AVG(DATEDIFF(p.fecha_registro, d.fecha_inicio)) % 365)/30), ' meses ',
              ROUND(AVG(DATEDIFF(p.fecha_registro, d.fecha_inicio)) % 30), ' días') 
              AS tiempo_promedio_construccion
    FROM desarrollos d
    JOIN propiedades p ON d.id_desarrollo = p.id_desarrollo
    WHERE p.estado != 'En construccion'
    GROUP BY d.tipo, p.tipo
) t ON d.tipo = t.tipo_desarrollo AND p.tipo = t.tipo_propiedad
WHERE p.estado = 'En construccion'
AND DATEDIFF(NOW(), d.fecha_inicio) > t.tiempo_promedio_dias
ORDER BY DATEDIFF(NOW(), d.fecha_inicio) DESC;

/*
**************************
*        FUNCION         *
**************************
*/

/*Función que devuelve la información acerca del cliente y los contratos que 
tiene con la empresa, el precio final pactado en el contrato, 
así como el monto que se ha pagado hasta hoy por contrato*/

DROP FUNCTION IF EXISTS resumen_cliente;

DELIMITER //
CREATE FUNCTION resumen_cliente(id_cliente INT) 
RETURNS TEXT
READS SQL DATA DETERMINISTIC
BEGIN
    DECLARE info_cliente TEXT;

    SELECT CONCAT('Nombre Completo: ',CONCAT_WS(' ',cl.nombre,cl.apellido_paterno,cl.apellido_materno),'\n',
                  '  Fecha de nacimiento: ',cl.fecha_nacimiento,'\n',
                  '  Correo: ',cl.correo,'\n',
                  '  Telefono: ',cl.telefono,'\n',
                  '  Contratos:\n',
                    IFNULL(GROUP_CONCAT(CONCAT(
                    '  ID Contrato: ', info.id_contrato,
                    ', Precio Final: $', FORMAT(info.precio_final, 2),
                    ', Monto Pagado: $', FORMAT(info.total_pagado, 2)
                ) SEPARATOR '\n'), '  Sin contratos')) 
    INTO info_cliente
    FROM clientes cl
    LEFT JOIN (
        SELECT c.id_cliente,c.id_contrato,c.precio_final,COALESCE(SUM(p.monto), 0) AS total_pagado
        FROM contratos c
        LEFT JOIN pagos p ON c.id_contrato = p.id_contrato
        GROUP BY c.id_cliente, c.id_contrato
    ) info 
    ON cl.id_cliente = info.id_cliente
    WHERE cl.id_cliente = id_cliente
    GROUP BY cl.id_cliente;

    RETURN info_cliente;
END //
DELIMITER ;

/*Ejemplos de uso de la FUNCION*/

SELECT resumen_cliente(2);
SELECT resumen_cliente(23);

/*
******************************
*  PROCEDIMIENTO ALMACENADO  *
******************************
*/

/*Procedimiento almacenado que permite insertar pagos, registrando de manera
automática el número de pago, y asegurando que dicho pago, junto con la suma
de los pagos anteriores no excedan la deuda que se tiene pendiente en el
respectivo contrato.*/

DROP PROCEDURE IF EXISTS registrar_pago;

DELIMITER $$
CREATE PROCEDURE registrar_pago(
    IN p_id_contrato INT, 
    IN p_fecha DATE, 
    IN p_monto DECIMAL(15,2), 
    IN p_metodo VARCHAR(50)
)
BEGIN
    DECLARE total_pagado DECIMAL(15,2);
    DECLARE nuevo_num_pago INT;

    SELECT IFNULL(SUM(monto), 0) INTO total_pagado
    FROM pagos 
    WHERE id_contrato = p_id_contrato;

    IF total_pagado + p_monto <= (SELECT precio_final 
                                  FROM contratos 
                                  WHERE id_contrato = p_id_contrato) 
    THEN
        SELECT IFNULL(MAX(num_pago), 0) + 1 INTO nuevo_num_pago
        FROM pagos 
        WHERE id_contrato = p_id_contrato;

        INSERT INTO pagos(num_pago, id_contrato, fecha_pago, monto, metodo_pago)
        VALUES (nuevo_num_pago, p_id_contrato, p_fecha, p_monto, p_metodo);
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El pago excede el monto faltante del contrato.';
    END IF;
END $$
DELIMITER ;

/*Ejemplo de uso del PROCEDIMIENTO ALMACENADO*/

-- informacion de pagos del contrato 92
SELECT * 
FROM pagos 
WHERE id_contrato = 92;

-- monto faltante
SELECT (c.precio_final - SUM(p.monto)) AS monto_faltante
FROM pagos p JOIN contratos c ON p.id_contrato = c.id_contrato
WHERE c.id_contrato = 92;

-- insertamos un monto válido (no excede el monto faltante)
CALL registrar_pago(92, '2025-06-01', 50000.00, 'Transferencia');

-- información de pagos del contrato 92 actualizada
SELECT * 
FROM pagos 
WHERE id_contrato = 92;

-- monto faltante actualizado
SELECT (c.precio_final - SUM(p.monto)) AS monto_faltante
FROM pagos p JOIN contratos c ON p.id_contrato = c.id_contrato
WHERE c.id_contrato = 92;

-- tratamos de insertar un monto no válido (excede el monto faltante)
CALL registrar_pago(92, '2025-06-01', 4000000.00, 'Transferencia');

/*
**************************
*        TRIGGER         *
**************************
*/

/*Trigger que verifica si al crear un nuevo contrato la propiedad 
relacionada está Disponible, y si es así, entonces actualiza el estado
de la propiedad a Vendida o Rentada según sea el tipo de contrato.*/

DROP TRIGGER IF EXISTS verificar_y_actualizar_propiedad;

DELIMITER %%
CREATE TRIGGER verificar_y_actualizar_propiedad
BEFORE INSERT ON contratos
FOR EACH ROW
BEGIN
    DECLARE estado_actual VARCHAR(50);

    SELECT estado INTO estado_actual
    FROM propiedades
    WHERE id_propiedad = NEW.id_propiedad;

    IF estado_actual != 'Disponible' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La propiedad no está disponible.';
    END IF;

    IF NEW.tipo = 'Venta' THEN
        UPDATE propiedades
        SET estado = 'Vendida'
        WHERE id_propiedad = NEW.id_propiedad;
    ELSEIF NEW.tipo = 'Renta' THEN
        UPDATE propiedades
        SET estado = 'Rentada'
        WHERE id_propiedad = NEW.id_propiedad;
    END IF;
END %%
DELIMITER ;

/*Ejemplo de uso del TRIGGER*/

-- Verificamos el estado de la propiedad 451 (Disponible)
SELECT id_propiedad,estado
FROM propiedades
WHERE id_propiedad = 451;

-- Se inserta un contrato para esa propiedad de Renta
INSERT INTO contratos (id_propiedad,id_agente,id_cliente,tipo,fecha_contrato,precio_final,forma_pago,condiciones_contractuales) VALUES
(451,73,99,'Renta','2025-05-10',9500000.00,'Pagos periodicos','El arrendatario no podrá subarrendar sin consentimiento por escrito.');

-- Verificamos nuevamente el estado de la propiedad 451 (Rentada)
SELECT id_propiedad,estado
FROM propiedades
WHERE id_propiedad = 451;

-- Tratamos de insertar un contrato para esa propiedad nuevamente
INSERT INTO contratos (id_propiedad,id_agente,id_cliente,tipo,fecha_contrato,precio_final,forma_pago,condiciones_contractuales) VALUES
(451,12,77,'Renta','2025-05-11',8750500.00,'Pago Unico','El arrendatario no podrá subarrendar sin consentimiento por escrito.');

-- Verificamos el estado de la propiedad 212 (Disponible)
SELECT id_propiedad,estado
FROM propiedades
WHERE id_propiedad = 212;

-- Se inserta un contrato para esa propiedad de Venta
INSERT INTO contratos (id_propiedad,id_agente,id_cliente,tipo,fecha_contrato,precio_final,forma_pago,condiciones_contractuales) VALUES
(212,40,65,'Venta','2025-05-12',7000000.00,'Pagos periodicos','Contrato vigente por 12 meses con opción a renovación.');

-- Verificamos nuevamente el estado de la propiedad 212 (Vendida)
SELECT id_propiedad,estado
FROM propiedades
WHERE id_propiedad = 212;

-- Tratamos de insertar un contrato para esa propiedad nuevamente
INSERT INTO contratos (id_propiedad,id_agente,id_cliente,tipo,fecha_contrato,precio_final,forma_pago,condiciones_contractuales) VALUES
(212,5,39,'Venta','2025-05-13',2560010.00,'Pagos periodicos','Contrato vigente por 12 meses con opción a renovación.');

-- Verificamos el estado de la propiedad 10 (En construccion)
SELECT id_propiedad,estado
FROM propiedades
WHERE id_propiedad = 10;

-- Tratamos de insertar un contrato para esa propiedad
INSERT INTO contratos (id_propiedad,id_agente,id_cliente,tipo,fecha_contrato,precio_final,forma_pago,condiciones_contractuales) VALUES
(10,25,42,'Venta','2025-05-15',1900000,'Pago Unico','El comprador se compromete a pagar el total en un plazo no mayor a 30 días.');




