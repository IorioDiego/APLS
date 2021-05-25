# TODO: 
# 1 - Help
# LISTO - Eliminar un archivo sin argumento (-f)
# LISTO - Comprimir y descomprimir papelera
# 4 - Ubicar la papelera donde dice el enunciado
# LISTO - Eliminar las salidas en la consola de algunos comandos.
# 6 - Agregar una salida por defecto para comando no encontrado.
# LISTO - Hacer los argumentos excluyentes. Ej: -e y -l
# 8 - Prevenir el mensaje de restaurar elementos si hay uno solo con ese nombre

[CmdletBinding( DefaultParameterSetName='addToTrash' )]
Param(
    [ValidateScript({ Test-Path $_ }, ErrorMessage="La ruta o archivo no existe.")]
    [Parameter(Mandatory, Position=0, ParameterSetName='addToTrash')]
    [String] $file,
    [Parameter(Mandatory, ParameterSetName='restore')]
    [String] $r,
    [Parameter(Mandatory, ParameterSetName='list')]
    [Switch] $l,
    [Parameter(Mandatory, ParameterSetName='clean')]
    [Switch] $e
)
    
Import-Module -Force "./utils/constants.ps1"
Import-Module -Force "./utils/helpers.ps1"

if($l) {
    Initialize;
    ListTrashFiles
}

if($r){
    Initialize -CreateTrash;
    UncompressTrash
    RestoreFile($r)
    CompressTrash
}

if($e){
    CleanTrash
}

if($file){
    Initialize -CreateTrash;
    UncompressTrash
    TrashFile($file)
    CompressTrash
}