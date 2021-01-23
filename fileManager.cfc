<!--- Interfaz para administración de archivos usando Cold Fusion 9 y Plupload  --->
<!--- Creador original: @Deadzombie18 https://github.com/DeadZombie18/pluploadCFinterface --->
<!--- Licencia de uso MIT https://github.com/DeadZombie18/pluploadCFinterface/blob/main/LICENSE  --->
<cfcomponent>
    <!--- Función: Obtener lista de archivos para Datatables --->
    <!--- Parametros: Ninguno --->
    <!--- Regresa: JQuery JSON --->
    <!--- IMPORTANTE: returnformat debe estar en "plain". Sino, regresará el contenido dentro de una etiqueta WWDX, rompiendo el JSON     --->
    <cffunction name="getFileList" access="remote" output="false" returnformat="plain">
        <cfset json = {}>
        <cfscript>
            var response = {};
            var data = [];
            var temp = {};
            var i = 0;
            var filenameArray = directoryList(expandPath("./uploads/"), false, "name", "", "file"); // Obtener la lista de nombres de archivo          
            // Crear JQuery JSON (objecto + arreglo + objetos)
            for (i = 1; i <= arrayLen(filenameArray); i++) {
                temp["name"] = filenameArray[i];
                arrayAppend(data,temp); 
                temp = {};
            }
            response["data"] = data; 
            json = serializeJSON(response); // Convertir a texto plano
        </cfscript>
        <cfreturn json/>
    </cffunction>

    <!--- Función: Subir archivo al servidor, adaptado para plupload --->
    <!--- Parametros: Ninguno --->
    <!--- Regresa: Respuesta de estado de subida --->
    <!--- Creador original: @johanstn https://gist.github.com/jsteenkamp/1116037 --->
    <cffunction name="upload" access="remote" returntype="struct" returnformat="json" output="false">
        <cfscript>
        var uploadDir = expandPath('.') & '/uploads/'; // Ubicación donde se guardaran los archivos 
        var uploadFile =  uploadDir & arguments.NAME;
        var response = {'result' = arguments.NAME, 'id' = 0};
        var result = {};
        // Si el archivo se sube por chunks (partes), asignar nombre unico a cada parte para poder reensamblar
        if (structKeyExists(arguments, 'CHUNKS')){
            uploadFile = uploadFile & '.' & arguments.CHUNK;
            response.id = arguments.CHUNK;
        }
        </cfscript>		
            
        <!--- Guardar chunk del archivo / archivo completo  allowedExtensions="*" --->
        <cffile action="upload" result="result" filefield="FILE" destination="#uploadFile#" nameconflict="overwrite"/>
            
        <cfscript>
        // Datos adicionales de archivo en respuesta
        response['size'] = result.fileSize;
        response['type'] = result.contentType;
        response['saved'] = result.fileWasSaved;
                
        // Reconstruir archivo por chunks
        if (structKeyExists(arguments, 'CHUNKS') && arguments.CHUNK + 1 == arguments.CHUNKS){
            try {
            var uploadFile = uploadDir & arguments.NAME; // Nombre de archivo y ubicacion final al reensamblar
            if (fileExists(uploadFile)){
                fileDelete(uploadFile); // Si ya existe el archivo, eliminar para crear nuevo
            }

            var tempFile = fileOpen(uploadFile,'append');
            for (var i = 0; i < arguments.CHUNKS; i++) {
                var chunk = fileReadBinary('#uploadDir#/#arguments.NAME#.#i#');
                fileDelete('#uploadDir#/#arguments.NAME#.#i#');
                fileWrite(tempFile, chunk);
            }
            fileClose(tempFile);
        }
            catch(any err){
            // Limpiar chunks corruptos
            var d = directoryList(uploadDir,false,'name');
            if (arrayLen(d) != 0){
                for (var i = 1; i <= arrayLen(d); i++){
                if (listFirst(d[i]) == arguments.NAME && val(listLast(d[i])) != 0){
                    fileDelete('#uploadDir##d[i]#');
                }
                }
            }
            // Informar de error al intentar reconstruir archivo 
            response = {'error' = {'code' = 500, 'message' = 'Internal Server Error'}, 'id' = 0};  
            }
        }
        return response;
        </cfscript>
    </cffunction>

    <!--- Función: Eliminar archivo del servidor --->
    <!--- Parametros: Lista de nombre de archivos --->
    <!--- Regresa: Respuesta de estado de eliminación --->
    <cffunction name="delete" access="remote" output="false" returnformat="json">
        <cfargument name="filename" type="string">
        <cfscript>
            var response = {'result' = "", 'id' = 0};
            var uploadDir = expandPath('.') & '/uploads/';
            var uploadedFile = "";
            uploadedFile = uploadDir & arguments.filename;
            if (fileExists(uploadedFile)){
                fileDelete(uploadedFile); // Si ya existe el archivo, eliminar para crear nuevo
                response["id"] = 1;
            }
            return response;
        </cfscript>
    </cffunction>

</cfcomponent>