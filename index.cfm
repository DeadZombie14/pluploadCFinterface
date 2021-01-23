<!--- Interfaz para administración de archivos usando Cold Fusion 9 y Plupload  --->
<!--- Creador original: @Deadzombie18 https://github.com/DeadZombie18/pluploadCFinterface --->
<!--- Licencia de uso MIT https://github.com/DeadZombie18/pluploadCFinterface/blob/main/LICENSE  --->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Archivos</title>

    <!-- Hojas de estilo -->
    <link rel="stylesheet" href="plugins/jquery-ui-1.10.4/themes/base/minified/jquery-ui.min.css" type="text/css" /> <!-- JQuery UI 1.10.4 -->
    <link rel="stylesheet" href="plugins/plupload/jquery.ui.plupload/css/jquery.ui.plupload.css" type="text/css" /> <!-- Plupload UI Widget CSS -->
    <link rel="stylesheet" type="text/css" href="plugins/DataTables/datatables.min.css"/> <!-- Datatables CSS -->
    <link rel="stylesheet" href="plugins/bootstrap-icons-1.3.0/bootstrap-icons.css"> <!-- Bootstrap Icons -->
    <style>
        /* Botones de acción */
        .btn {
            background-color: DodgerBlue;
            border: none;
            color: white;
            padding: 12px 16px;
            font-size: 16px;
            cursor: pointer;
            margin: 12px;
        }
        /* Botones de acción datatables*/
        .btn-table {
            margin: 0px;
        }
        
        .btn:hover {
            background-color: RoyalBlue;
        } 
        
        #refreshTable {
            margin-top: 0px;
            margin-bottom: 0px;
        }

        #fileDisplay {
            border-bottom: solid;
            border-width: 1px;
        }

        .fileManagerContainer {
            font-family: Arial;
            border-style: solid;
            border-width: 1px;
        }
        .fileManagerContainer h3 {
            border-bottom: solid;
            border-width: 1px;
        }
    </style>
</head>
<body>
    <!-- Formulario principal + Plupload UI widget -->
    <!-- Es importante incluir la ultima función JQuery del final en caso de usar en formulario, 
         para evitar que se envien los datos sin subir los archivos -->
    <form id="form" method="post" action="#">
        <div id="uploader">
            <p>Your browser doesn't have Flash, Silverlight or HTML5 support.</p>
        </div>
        <br />
        <button type="submit" class="btn"><i class="bi bi-arrow-up-square"></i>  Subir archivos</button>  <!-- Boton para enviar y subir formulario de datos -->
    </form>

    <!-- Administrador de archivos en servidor -->
    <div class="fileManagerContainer">
        <center><h3>Lista de archivos en servidor</h3></center>
        <button type="button" class="btn" id="refreshTable"><i class="bi bi-arrow-clockwise"></i>  Actualizar</button>
        <table id="fileDisplay" class="display" style="width: 100% !important;">
            <thead>
                <tr>
                    <th>Nombre de archivo</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    </div>

    <!-- Javascripts -->
    <script src="plugins/jquery-3.5.1.min.js"></script> <!-- JQuery -->
    <script type="text/javascript" src="plugins/jquery-ui-1.10.4/ui/minified/jquery-ui.min.js"></script> <!-- JQuery UI 1.10.4 -->
    <script src="plugins/plupload/plupload.full.min.js"></script> <!-- Plupload -->
    <script type="text/javascript" src="plugins/plupload/jquery.ui.plupload/jquery.ui.plupload.js"></script> <!-- JQuery Plupload UI Widget -->
    <script type="text/javascript" src="plugins/plupload/i18n/es.js"></script> <!-- Idioma español para Plupload UI Widget -->
    <script type="text/javascript" src="plugins/DataTables/datatables.min.js"></script> <!-- Datatables -->
    <script type="text/javascript">
        $(document).ready( function () {
            // Configuración para tabla Datatable de archivos
            var table = $('#fileDisplay').DataTable({
                paging: false,
                searching: false,
                ordering:  false,
                info: true,
                select: true,
                scrollY: "500px",
                scrollCollapse: true,
                ajax: {
                    url: "fileManager.cfc?method=getFileList",
                    dataSrc: "data"
                },
                columns: 
                [   
                    { 
                        title:'Nombre de archivo',
                        data: "name"
                    },
                    {
                        title: "Acciones",
                        orderable: false,
                        data: null,
                        defaultContent: `
                            <center>
                                <button type="button" class="btn btn-table"><i class="bi bi-trash"></i>  Eliminar</button>
                            </center>
                            `,
                        width: "150px"
                    }
                ],
                language: {
                    lengthMenu: "Ver _MENU_ elementos por página",
                    zeroRecords: "No se encontraron archivos en el servidor.",
                    info: "_MAX_ archivos encontrados.",//"Mostrando página _PAGE_ de _PAGES_",
                    infoEmpty: "No hay archivos a mostrar.",
                    infoFiltered: "(filtrados de un total de _MAX_ archivos)"
                }
            });

            // Configuración de Plupload UI widget para carga de archivos
            var uploaderWidget = $("#uploader").plupload({
                runtimes : 'html5,flash,silverlight,html4',
                url : 'fileManager.cfc?method=upload',
                max_file_count: 300, // Cantidad maxima de archivos
                chunk_size: '1mb', // Tamaño maximo de partes a subir
                autostart: false,
                rename: true,
                sortable: true,
                dragdrop: true,
                prevent_duplicates: true,
                buttons: {
                    browse: true,
                    start: false,
                    stop: false,
                },
                // Si se suben imagenes, recortar a un tamaño exacto
                resize : {
                    width : 200, 
                    height : 200, 
                    quality : 90,
                    crop: true
                },
                filters : {
                    max_file_size : '50kb', // Tamaño maximo por archivo
                    mime_types: [ // Tipos de archivo admitidos
                        {title : "Documentos XML", extensions : "xml"}
                    ]
                },
                views: {
                    list: true,
                    thumbs: true,
                    active: 'list'
                },
                // Flash settings
                flash_swf_url : 'js/Moxie.swf',
                // Silverlight settings
                silverlight_xap_url : 'js/Moxie.xap'
            });

            // Ajax de acción al hacer click en eliminar
            $('#fileDisplay tbody').on( 'click', 'button', function () {
                var data = table.row( $(this).parents('tr') ).data();
                if(confirm("Eliminar del servidor: " + data["name"] + " ? (Permanentemente)")) {
                    $.ajax({
                        type: 'POST',
                        url: 'fileManager.cfc?method=delete',
                        data: {"filename": data["name"]}
                    })
                    .done(function(data) {
                        table.ajax.reload();
                        // console.log("Archivo eliminado. Actualizando tabla...");
                    })
                    .fail(function() {
                        alert("Error al intentar eliminar el archivo.");
                    });
                }
            } );

            // Al hacer click en actualizar, volver a ejecutar el ajax de la tabla
            $('#refreshTable').on('click', function() {
                table.ajax.reload();
                console.log("Actualizando tabla...");
            });

            // Evento: Al terminar de subir archivos, refrescar ajax de la tabla
            $('#uploader').on('complete', function() {
               table.ajax.reload();
            //    console.log("Archivo subido. Actualizando tabla..."); 
            });
            
            $('#uploader').on('error', function(instance, error, file, status) {
               //alert(error);
            });

            // IMPORTANTE PARA FORMULARIOS CON PLUPLOAD
            // Inicia la carga de archivos al servidor al hacer click en "Enviar formulario"
            // No permitirá enviar el formulario hasta que los archivos se hayan subido al servidor.
            $('#form').submit(function(e) {
                if ($('#uploader').plupload('getFiles').length > 0) {
                    // Iniciar y esperar a que se suban los archivos, luego enviar el formulario.
                    $('#uploader').on('complete', function() {
                        $('#form')[0].submit();
                    });
                    $('#uploader').plupload('start');
                } else {
                    alert("Espera a que terminen de subir los archivos."); // Mensaje en caso de que el usuario vuelva a dar click
                }
                return false; // Evita que el formulario sea enviado
            });
        });
    </script>
    
</body>
</html>