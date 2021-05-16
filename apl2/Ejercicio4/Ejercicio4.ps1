# +++++++++++++++ENCABEZADO+++++++++++++++++++++++++++
# Nombre script: Ejercicio2.sh
# Trabajo Práctico Nro. 1 (GRUPAL)
# Ejercicio: 2
# Integrantes:
  #  Cardozo Emanuel                    35000234
  #  Iorio Diego                        40730349
  #  Paz Zarate Evelyn  Jessica         37039295
  #  Perez Lucas Daniel                 39656325
  #  Ramos Marcos                       35896637
# Nro entrega: Primera Entrega
# +++++++++++++++FIN ENCABEZADO+++++++++++++++++++++++


<#
    .SYNOPSIS
   
    
    .DESCRIPTION
   
    .EXAMPLE
    

    .EXAMPLE

#>

Param(

    [Parameter (Mandatory = $true,ParameterSetName="grupo1")]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {
            if ( -Not (Test-Path $_ )) {
                throw "El Path no existe"
            }
            return $true
        })]
    $Descargas,

    [Parameter (ParameterSetName="grupo1")]
    $Destino,
    [Parameter (ParameterSetName="grupo2")]
    [switch]$Detener

)

if($Detener){
    Unregister-Event -SourceIdentifier FileCreated
    Write-Host "hola"
    exit 0
}

if($Destino -eq $null ){
    $Destino=$Descargas
}


$global:Descargas=$Descargas
$global:Destino=$Destino
#$pathCompleto= Get-ChildItem $Destino -recurse | % { Write-Host $_.FullName} 
$pathCompletoDestino=Resolve-Path $Destino
$pathCompletoDescargas=Resolve-Path $Descargas
#Write-Host $pathCompleto
$filter= "*.*"
$fileSystemWatcher = New-Object IO.FileSystemWatcher $pathCompletoDescargas, $filter -Property @{
    IncludeSubdirectories = $true
    NotifyFilter = [IO.NotifyFilters]"FileName, LastWrite"

}

$onCreated = Register-ObjectEvent $fileSystemWatcher Created -SourceIdentifier FileCreated -Action{
$path = $Event.SourceEventArgs.FullPath 
$n=@(dir $path | select  BaseName,Extension)
#$n.Extension="$n.Extension" | ForEach-Object {$_ -replace '\.', 'x'}
$pathCompletoDestino=Resolve-Path $Destino
$pathCompletoDescargas=Resolve-Path $Descargas
$ex=$n.Extension
$ex=$ex -replace "^."
$ex="$ex".ToUpper()
New-Item "$pathCompletoDestino/$ex" -Type Directory
Move-Item -Path $path -Destination "$pathCompletoDestino/$ex" -PassThru
}



# Push-Location -Path $pathCompleto # me muevo a esta direccion

# Get-ChildItem
# Get-Location #obtengo la direccion donde estoy parado

# Pop-Location # vuelvo a donde estaba antes
# Get-Location




# if [ $1 != $2 ]
#                         then
#                                 IFS=$'\n'
#                                 newFiles=($(ls -1a "$1"))
#                                 for elem in ${newFiles[@]}
#                                 do
#                                         echo "archivo :$elem"
#                                         primerCar=$(expr substr $elem 1 1)
#                                         if [ $primerCar == '.' ]
#                                         then
#                                                 extension=$(echo $elem | awk -F . '{print $3}')
#                                         else
#                                                 extension=$([[ "$elem" = *.* ]] && echo "${elem##*.}") 
#                                         fi
#                                         primerCar=$(expr substr $elem 1 1)
#                                                 if [ -z $extension ] || ([ -z $extension ] && [ $primerCar == "." ])
#                                                 then 
#                                                         mv "$1/$elem" "$2"
#                                                 else
#                                                         directorio=0
#                                                         ciclos=0   
#                                                         mkdir "$2/temp"    
#                                                         destiny=($(ls -l $2 | grep ^d | awk '{print $9}'))
                                                        
#                                                         for d in ${destiny[@]}
#                                                         do
#                                                                 ciclos=$(( ciclos + 1))
#                                                                 if [[ "${d,,}" == "${extension,,}" ]]
#                                                                 then
#                                                                         directorio=1
#                                                                         mv "$1/$elem" "$2/$d"
#                                                                 else 
#                                                                         mkdir "$2/${extension^^}"
#                                                                         mv "$1/$elem" "$2/${extension^^}"
#                                                                 fi
#                                                         done
#                                                         rmdir $2/temp
#                                                 fi
#                                 done
#                         fi
#                         oldStat=$newStat
#                         unset IFS