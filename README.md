# Desarrollos Inmobiliarios

## Sobre la Base de Datos
La base de datos corresponde a los registros de los inmuebles y las distintas operaciones de construcción y compra/venta que realiza una empresa dedicada al desarrollo inmobiliario. Está estructurada en 13 tablas, de la siguiente manera:
* *desarrollos*: Información sobre el nombre y tipo de desarrollo así como la fecha de inicio y fin de construcción.
* *propiedades*: Información sobre el tipo de propiedad, su dirección y otras características como estado de venta, área y precio.
* *agentes*: Detalles de los agentes inmobiliarios de la empresa, como su nombre, sexo, fecha de nacimiento, correo y teléfono.
* *clientes*: Detalles de los clientes de la empresa, como su nombre, sexo, fecha de nacimiento, correo y teléfono.
* *contratos*: Información sobre los contratos que tiene la empresa con sus clientes, destacando la propiedad, el cliente, y el agente involucrados, el precio final, la fecha, tipo de contrato (venta/renta) y las condiciones contractuales.
* *pagos*: Información sobre los pagos realizados, como el contrato asociado, fecha de pago, el monto y el método de pago.
* *interacciones*: Registros de las interacciones que han tenido los agentes inmobiliarios con los clientes.
* *agente_propiedad*: Ayuda a relacionar a los agentes inmobiliarios con las distintas propiedades que tienen asignadas.
* *direcciones*: Direcciones correspondientes a cada una de las propiedades, detallando calle, números exterior e interior y la colonia.
* *colonias*: Registro de las colonias.
* *municipios*: Registro de todos los municipios de México.
* *estados*: Registro de los 32 estados de México.

## Objetivos
* Diseñar una base de datos bien estructurada y normalizada que permita llevar el control de los inmuebles y operaciones de la empresa, usando un diagrama entidad-relación.
* Implementar el diseño del diagrama entidad-relación en SQL, estableciendo correctamente el tipo de datos y las relaciones entre tablas así como las restricciones adecuadas para mantener la consistencia de la base de datos, y poblar la base de datos con registros reales y consistentes.
* Realizar consultas que permitan obtener insigths sobre las tendencias de compra/venta de los inmuebles, clientes potenciales, agentes inmobiliarios efectivos, estado de las propiedades, etc., así como implementar funciones, procedimientos almacenados y disparadores que permitan automatizar procesos.

## Resultados
Se realizaron las siguientes consultas:
* Obtener la cantidad total de propiedades que se tienen registradas por desarrollo,así como la cantidad de propiedades que se han logrado vender y/o rentar por desarrollo, y la proporción entre las propiedades vendidas y/o rentadas y el total de propiedades.
* Obtener un resumen de todos los agentes y la cantidad de contratos que han cerrado, así como la cantidad total de ingresos que han generado dichos contratos a la empresa.
* Mostrar a los clientes que han firmado al menos un contrato y cuántos contratos han firmado,  así como el número total de interacciones que tuvieron esos clientes con los agentes, y el promedio de interacciones por contrato firmado.
* Mostrar la cantidad de propiedades registradas por estado, así como la cantidad de propiedades que se han logrado vender o rentar, la proporción entre las propiedades vendidas y/o rentadas respecto al total de propiedades, y el total de ingresos generados.
* Mostrar un resumen por tipo de desarrollo y por tipo de propiedad que detalle las propiedades totales, las propiedades vendidas y rentadas, los ingresos generados por ventas y/o rentas, y la proporción entre las propiedades vendidas y/o rentadas y las propiedades totales.
* Encontrar a los clientes que todavía no liquidan algunos de sus contratos por completo, mostrando un resumen del precio final pactado en sus contratos, la cantidad que han pagado hasta el momento, el porcentaje pagado respecto al valor de la propiedad, así como el  plazo que han tenido desde que se firmó el contrato.
* ¿Cuál es el tiempo minimo,promedio,y maximo (en días), que se tardan en vender o rentar las propiedades desde que se registran hasta que se firma un contrato, agrupadas por tipo de desarrollo y tipo de propiedad?
* Obtener los nombres completos de los clientes junto con los nombres completos del/los agente(s) con el(los) que han interactuado el mayor número de veces, así como la cantidad de interacciones entre el cliente y el/los agente(s).
* ¿Cuál es el tiempo minimo,promedio y máximo que han tardado todas las propiedades de la empresa que ya están concluidas en construirse, agrupadas por tipo de desarrollo y tipo de propiedad?
* ¿Cuáles son las propiedades que la empresa sigue teniendo en construcción y ya han superado el tiempo promedio de construcción correspondiente a su tipo de desarrollo y propiedad?

Adicionalmente, se incluyó:
* Una función que devuelve la información acerca del cliente y los contratos que tiene con la empresa, el precio final pactado en el contrato, así como el monto que se ha pagado hasta hoy por contrato.
* Un procedimiento almacenado que permite insertar pagos, registrando de manera automática el número de pago, y asegurando que dicho pago, junto con la suma de los pagos anteriores no excedan la deuda que se tiene pendiente en el respectivo contrato.
* Un disparador que verifica si al crear un nuevo contrato la propiedad relacionada está Disponible, y si es así, entonces actualiza el estado de la propiedad a Vendida o Rentada según sea el tipo de contrato.

# Sobre los archivos del repositorio
| Archivo                                                  | Descripción                                                                                                      |
|----------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| `DER/DER.pdf`                                            | Diagrama Entidad-Relación de la base de datos                                                                    |
| `creacion e insercion/creacion_e_insercion.sql`          | Archivo SQL para crear la base de datos, crear las tablas y poblar la base de datos                              |
| `consultas y funciones/consultas_y_funciones.sql`        | Archivo SQL para realizar las consultas y agregar las funciones, procedimientos almacenados y disparadores       |
| `consultas y funciones/ejecucion consultas y funciones`  | Archivo de texto que muestra la ejecución y los resultados de las consultas del archivo consultas_y_funciones.sql|            
