# +++++++++++++++ENCABEZADO+++++++++++++++++++++++++++
# Nombre script: Ejercicio5.ps1
# Trabajo Práctico Nro. 2 (GRUPAL)
# Ejercicio: 5
# Integrantes:
  #  Cardozo Emanuel                    35000234
  #  Iorio Diego                        40730349
  #  Perez Lucas Daniel                 39656325
  #  Ramos Marcos                       35896637
# Nro entrega: Primera Entrega
# +++++++++++++++FIN ENCABEZADO+++++++++++++++++++++++

<#
    .SYNOPSIS
        Script que se comporta como una papelera de reciclaje comprimida
    .DESCRIPTION
        Se envían y eliminan tanto archivos como directorios a una carpeta comprimida, a la cual
        se tiene acceso para listar, restaurar, enviar elementos o vaciar la propia papelera.
    .NOTES
        La papelera se descomprime cuando se restauran o envian elementos.
    .INPUTS
        <ruta del elemento>             [Envía el elemento a la papelera]
        -l                              [Lista los elementos dentro de la papelera]
        -e                              [Vacía la papelera]
        -r <nombre del elemento>        [Restaura un elemento de la papelera a su ubicación original]
    .OUTPUTS
        [ruta al home]/Papelera.zip
        La Papelera que contiene todos los elementos eliminados.
        
        [ruta del script]/index.txt
        Un archivo que gestiona los paths de origen y nombres de los elementos
    .EXAMPLE
        ENVIAR UN ELEMENTO A LA PAPELERA

        ./ejercicio6.ps1 [ruta del elemento]

        De esta manera, se agrega un elemento a la papelera que si no existe, se crea.
    .EXAMPLE
        RESTAURAR UN ELEMENTO

        ./ejercicio6.ps1 -r [nombre del elemento]

        Se restaura el elemento con el nombre ingresado. En caso de haber varios con el
        mismo nombre, se muestra un menú de opciones para indicar cuál es el deseado. Si
        la papelera queda vacía la misma se elimina junto con su archivo index.txt.
    .EXAMPLE
        VACIAR PAPELERA

        ./ejercicio6.ps1 -e

        Se elimina la papelera junto con el archivo index.txt.
    .EXAMPLE
        LISTAR ELEMENTOS DE LA PAPELERA
        
        ./ejercicio6.ps1 -l

        Se muestra una tabla con el nombre y el Path de origen de los elementos que se
        encuentran dentro de la papelera.
#>

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
    
Import-Module -Force "./utils/compressor_handlers.ps1"
Import-Module -Force "./utils/constants.ps1"
Import-Module -Force "./utils/helpers.ps1"
Import-Module -Force "./utils/main.ps1"

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