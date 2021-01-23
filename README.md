# pluploadCFinterface
Proyecto ColdFusion 9 para carga y administración de archivos usando Plupload.

Datatables, Boostrap Icons, Jquery, Jquery UI son usados en base a su licencia MIT.
Plupload utiliza licencia AGPL.
Todos estos componentes cuentan con su información de licencia y están intactos de sus respectivas fuentes.

Detalles del proyecto
--------------------
Para poder utilizarlo se requiere especificamente de Cold Fusion 9. El proyecto hace uso de JQuery y JQueryUI.

IMPORTANTE: Crear una carpeta llamada "uploads" en la raiz del proyecto para que ColdFusion proceda a almacenar los archivos en la misma.

Si usas una versión superior de Cold Fusion es necesario modificar el archivo fileManager.cfc y añadir la tag 
`allowedExtensions=*`
en la función upload. Esto debido a que las versiones mas recientes no admiten la carga de archivos sin nombre al servidor, rompiendo la dinámica de subida por chunks de Plupload.

Datatables es utilizado para poder mantener visible una lista de archivos en el servidor y eliminar algunos en caso de ser necesario.
