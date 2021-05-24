# TODO: 
# 1 - Help
# 2 - Eliminar un archivo sin argumento (-f)

# 4 - Ubicar la papelera donde dice el enunciado
# 5 - Eliminar las salidas de los Add de los arrays
# 6 - Agregar una salida por defecto para comando no encontrado.
# 7 - Hacer los argumentos excluyentes. Ej: -e y -l

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