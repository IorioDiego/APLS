# +++++++++++++++ENCABEZADO+++++++++++++++++++++++++++
# Nombre script: Ejercicio4.ps1
# Trabajo Práctico Nro. 2 (GRUPAL)
# Ejercicio: 4
# Integrantes:
#  Cardozo Emanuel                    35000234
#  Iorio Diego                        40730349
#  Perez Lucas Daniel                 39656325
# Nro entrega: Segunda Entrega
# +++++++++++++++FIN ENCABEZADO+++++++++++++++++++++++

<#
    .SYNOPSIS
    El script cambia el evento de creacion de archivos ,en una carpeta especifica, para que cuando se
    de ese evento , el archivo sea movido a otro directorio tambien especificado
    
    .DESCRIPTION
    El usuario envia como paramtros la carpeta descargas que sera monitoreada, y la destino carpeta
     (si no es especificada sera la misma que la de descargas) donde seran enviandos los archivos 
     descargados   

    .EXAMPLE
    ./Ejercicio4.ps1 -Destino carpeta_destino -Descargas carpeta_a_monitorear 
    ./Ejercicio4.ps1 -Descargas carpeta_a_monitorear -Destino carpeta_destino
    ./Ejercicio4.ps1 -Detener

#>

Param(

    [Parameter (Mandatory = $true, ParameterSetName = "grupo1")]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {
            if ( -Not (Test-Path $_ )) {
                throw "El Path no existe"
            }
            return $true
        })]
    $Descargas,

    [Parameter (ParameterSetName = "grupo1")]
    $Destino,
    [Parameter (ParameterSetName = "grupo2")]
    [switch]$Detener

)

if ($Detener) {
    Unregister-Event -SourceIdentifier FileCreated
    exit 0
}

if ($Destino -eq $null ) {
    $Destino = $Descargas
}


$global:Descargas = $Descargas
$global:Destino = $Destino

$pathCompletoDestino = Resolve-Path $Destino
$pathCompletoDescargas = Resolve-Path $Descargas

$filter = "*.*"
$fileSystemWatcher = New-Object IO.FileSystemWatcher $pathCompletoDescargas, $filter -Property @{
    IncludeSubdirectories = $true
    NotifyFilter          = [IO.NotifyFilters]"FileName, LastWrite"

}

$onCreated = Register-ObjectEvent $fileSystemWatcher Created -SourceIdentifier FileCreated -Action {
    $path = $Event.SourceEventArgs.FullPath 
    $n = @(dir $path | select  BaseName, Extension)
    $pathCompletoDestino = Resolve-Path $Destino
    $pathCompletoDescargas = Resolve-Path $Descargas

    $r = Split-Path -Path $path

    $p = $path -replace "$r/", ""
  
    $canP = ($p -split '\.').count
    



    
    if (($ex -eq "" ) -and ($canP -eq 3)) {
    
        $extensionOculto = Split-Path -Extension $path
        $extensionOculto = $extensionOculto -replace "^."
        $extensionOculto = "$extensionOculto".ToUpper()
        New-Item "$pathCompletoDestino/$extensionOculto" -Type Directory
        Move-Item -Path $path -Destination "$pathCompletoDestino/$extensionOculto" -PassThru -Force #muevo los archivos y los sobreeescribo con el -force
        
    
    }
    else {
        
        $ex = $n.Extension
        $ex = $ex -replace "^."
        $ex = "$ex".ToUpper()
        New-Item "$pathCompletoDestino/$ex" -Type Directory
        Move-Item -Path $path -Destination "$pathCompletoDestino/$ex" -PassThru -Force #muevo los archivos y los sobreeescribo con el -force
    
    }

}

