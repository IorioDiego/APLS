# +++++++++++++++ENCABEZADO+++++++++++++++++++++++++++
# Nombre script: Ejercicio2.sh
# Trabajo Práctico Nro. 1 (GRUPAL)
# Ejercicio: 6
# Integrantes:
  #  Cardozo Emanuel                    35000234
  #  Iorio Diego                        40730349
  #  Paz Zarate Evelyn  Jessica         37039295
  #  Perez Lucas Daniel                 39656325
  #  Ramos Marcos                       35896637
# Nro entrega: 1
# +++++++++++++++FIN ENCABEZADO+++++++++++++++++++++++

<#
.SYNOPSIS
    El Script simula el uso de una Papelera de reciclaje.
.Description
    Las opciones disponibles son las siguientes:
    
    LISTAR
    -l : Se listan todos los archivos dentro de la papelera de reciclaje. 
    
    VACIAR PAPELERA
    -e: Se vacia la papelera de reciclaje, eliminando permanentemente los archivos que la papelera contenga.
    
    RECUPERACION DE ARCHIVOS
    -r: Se podrán recuperar archivos enviandolos a la ruta de origen. Se debe indicar el nombre del archivo.
    
    ENVIAR ARCHIVO A LA PAPELERA
    Para enviar un archivo a la papelera de reciclaje se debe indicar el nombre del elemento a mover.
.Example
    Ejercicio6 ps1 nombreArchivo
    Ejercicio6 ps1 -l
    Ejercicio6 ps1 -r nombreArchivo    
    Ejercicio6 ps1 -e 
    
    Aclaraciones:
    El orden para tanto para comprimir o descomprimir puede ser el que desee
    
#>


# function Listar-Papelera {

#     return $true
# }

# function Borrar-Papelera {

#     return $true
# }

# function Recuperar-Archivo {

#     param(
#     [Parameter(Mandatory = $true)]
#     [ValidateNotNullOrEmpty()]
#     [ValidateScript( {
#         if ( -Not(Test-Path $_ -PathType Leaf)) {
#             Write-Host "puto"
#             throw  "archivo $_ no existe."
#             return $false
#         }
#         return $true
#     })]
#     [String]$archivo

#     )
#     Write-Host $archivo
#     return $true
# }

# function Borrar-Archivo {

#     Param(
#     [Parameter(Mandatory = $true)]
#     $archivo

#     )
#     return $true
# }

Param(

    [Parameter(Mandatory = $false)]
    $archivo,
    [Parameter(Mandatory = $false)]
    $opcion
    )

function Descomprimir{


    # $PATH_PAPELERA="tmp"
    # $myLocation = Get-Location
    # Set-Location ~    
    # $h = Get-Location

    if( Test-Path "Papelera.zip"){
       
       Expand-Archive -DestinationPath "$h/papelera" -LiteralPath  "Papelera.zip" 

    }else {
        New-Item "papelera" -ItemType Directory
        New-Item "papelera/ListadoDeArchivosEnLaPapelera.txt" -ItemType "File"

    }
    
    #Compress-Archive -Path "papelera/ListadoDeArchivosEnLaPapelera.txt" -DestinationPath "Papelera.zip"  -Update
   
    Set-Location $myLocation
    
#Compress-Archive -Update @compress 

#  $compress = @{
#           LiteralPath= "ListadoDeArchivosEnLaPapelera.txt"
#          CompressionLevel = "Fastest"
#           DestinationPath = "Papelera.zip"
#          }




}


function comprimirArch {
   

    param (
        $archivo
    )
    $rutaDelArchivo =Resolve-Path $archivo
    Write-Host $rutaDelArchivo
    $myLocation = Get-Location
    $n=@(dir $archivo | select  BaseName,Extension)
    $nombre=$n.BaseName
    $ex=$n.Extension
    Write-Host rutaDelArchivo
    Set-Location ~    
    $h = Get-Location
   Descomprimir
    #$rutaDelArchivo=Get-ChildItem -Path $archivo -Filter $a -Recurse | %{$_.FullName} 
    $id=((Get-Content $h/papelera/ListadoDeArchivosEnLaPapelera.txt).count)+1
   Add-Content -Value "$nombre$ex,$rutaDelArchivo,$id"  -Path "$h/papelera/ListadoDeArchivosEnLaPapelera.txt"  
   
   
   Move-Item $rutaDelArchivo "$h"
   Rename-Item "$h/$nombre$ex" -NewName "$id$ex"
   Move-Item "$h/$id$ex" "$h/papelera"

     $compress = @{
                    LiteralPath= "$h/papelera/ListadoDeArchivosEnLaPapelera.txt" 
                    CompressionLevel = "Fastest"
                    DestinationPath = "$h/Papelera.zip"
                   }
    Compress-Archive -Update @compress 
    $compress = @{
                    LiteralPath= "$h/papelera/$id$ex" 
                    CompressionLevel = "Fastest"
                    DestinationPath = "$h/Papelera.zip"
                   }
                
   Compress-Archive -Update @compress 
   Remove-Item "$h/papelera" -Recurse 
    Set-Location $myLocation
}

function recuperArchivo {

    param (
        $archivoExtraer
    )

    $myLocation = Get-Location
    Set-Location ~    
    $h = Get-Location
    Descomprimir
   # $archivoExtraer=$Args[1]


                # $id=((Get-Content $HOME\$Archivos\misRutas.txt).Length)+1
                # $test3="$test1,$test2,$id"

                # #Set-Content -Value $test -Path $HOME\$Archivos\misRutas.txt
                # Add-Content -Value $test3 -Path $HOME\$Archivos\misRutas.txt

                #guardo nombres + ruta + txt

    

             Get-Content $h/papelera/ListadoDeArchivosEnLaPapelera.txt | sort | Set-Content $h/temp.txt

            $nombresElim=Get-Content $h/temp.txt | ForEach-Object {"$(($_ -split ',',3)[0])"} #Guardo el nombre

            $rutaElim=Get-Content $h/temp.txt | ForEach-Object {"$(($_ -split ',',3)[1])"} #Guardo la ruta

            $miID=Get-Content $h/temp.txt | ForEach-Object {"$(($_ -split ',',3)[2])"}
          

            $index = New-Object System.Collections.ArrayList
            write-host $archivoExtraer
                 $count=0
                 $inicio=-1
                 for ($i = 0; $i -lt $nombresElim.Count; $i++) {
                     if($nombresElim[$i] -eq $archivoExtraer)
                         {
                                 $count++
                                 if($inicio -eq -1)
                                     {
                                     $inicio=$i
                                     } 
                                $index.Add("$i")
                                write-host "gola
                                "
                         }
                 }

              
                for ($i = 0; $i -lt $nombresElim.Count; $i++){
                    Write-Host ($nombresElim[$i] +"                 "+$rutaElim[$i])
                    }
                    
                #  for ($i = $inicio; $i -lt ($count+$inicio); $i++){
                #       Write-Host ($miID[$i]+" - "+$nombresElim[$i] +"                 "+$rutaElim[$i])
                #        }

                    foreach ($item in $index) {
                        Write-Host ($miID[$item]+" - "+$nombresElim[$item] +"           "+$rutaElim[$item])
                    }
                                
                 Write-Host "ESCOJA EL NUMERO DEL ARCHIVO QUE QUIERA DESCOMPRIMIR"
                $numeroSeleccionado=Read-Host 
                
                $elegido=Get-Content $h/papelera/ListadoDeArchivosEnLaPapelera.txt | Where-Object {$_ -match "$numeroSeleccionado"}
                #$cadena =Select-String -Path $h/papelera/ListadoDeArchivosEnLaPapelera.txt -Pattern '$numeroSeleccionado' -AllMatches -Raw
                #Get-Content $h/papelera/ListadoDeArchivosEnLaPapelera.txt | Where-Object {$_ -notmatch "$numeroSeleccionado"} | Set-Content $h/temp
                #Get-Content $h/temp | Set-Content $h/papelera/ListadoDeArchivosEnLaPapelera.txt
                #Remove-Item $h/temp
               
                $pos=0
               
               for ($i = 0; $i -lt $miID.Count; $i++) {
                   if ($miId -eq $numeroSeleccionado){
                       $pos=$i;
                   }
               }
               $rutaElegido = $rutaElim[$pos]
               $rutaElegido=   Split-Path -Path "$rutaElegido"
                Write-Host  $elegido
                Write-Host $rutaElegido
            #    foreach ($item in $elegido) {
            #         Write-Host "$item -"
            #    }
               $a=(Get-Item $elegido[2]).DirectoryName 
               Write-host $a 
               Remove-Item "$h/papelera" -Recurse 
               
                Set-Location $myLocation
                
}


if("$opcion" -eq "r"){ 

    recuperArchivo $archivo

}else {
    comprimirArch -archivo $archivo
}





                # function  Comprimir($a) {
                    
                    
                #     $rutaDelArchivo=Get-ChildItem -Path $HOME\* -Filter $a -Recurse | %{$_.FullName}  
                    
                    
                #     $compress = @{
                #         LiteralPath= "$rutaDelArchivo"
                #         CompressionLevel = "Fastest"
                #         DestinationPath = "$HOME\Draft.Zip"
                #         }
                #         Compress-Archive -Update @compress 
                    
                # }

                # function  Listar {
                    
                #     $content = [IO.File]::ReadAllText("$HOME\$Archivos\misRutas.txt")
                #     Write-Output $content
                # }


                # Write-Output "ESTO ES HOME:$HOME" 

                # Write-Output $Args[0]


                # #Comprimir $Args[0]



                # $Archivos="Archivos" #Como se va a llamar la carpeta
                # #New-Item -Path $HOME -Name $Archivos -ItemType "directory" 
                # #New-Item -Path $HOME\$Archivos -Name misRutas.txt -ItemType "file" 

                # $test1=$Args[0]
                # $test2=Get-ChildItem -Path $HOME\* -Filter $Args[0] -Recurse | %{$_.FullName} 
               
               
               
             



























#$Archivos="Archivos" #Como se va a llamar la carpeta
#New-Item -Path $HOME -Name $Archivos -ItemType "directory" 
#New-Item -Path $HOME\$Archivos -Name misRutas.txt -ItemType "file" 

    # $test1=$Args[0]
    # $test2=Get-ChildItem -Path $HOME\* -Filter $Args[0] -Recurse | %{$_.FullName} 

    # $test3="$test1,$test2"
    # #Set-Content -Value $test -Path $HOME\$Archivos\misRutas.txt
    # Add-Content -Value $test3 -Path $HOME\$Archivos\misRutas.txt
    # Write-Output ""






    # $var=Get-Content $HOME\$Archivos\misRutas.txt -Replace ',','A'
    # Write-Output $var


    #     $PATH_PAPELERA="/home/PapeleraDeReciclaje"
    #     Descomprimir 
    
    # $myLocation = Get-Location

    # Set-Location ~
    
    
    # Set-Location $myLocation


    # $ruta =Resolve-Path $archivo


#$ruta= Get-ChildItem -Path /home/* -Filter $archivo -Recurse | %{$_.FullName}  

    #  $compress = @{
    #      LiteralPath= "$ruta"
    #      CompressionLevel = "Fastest"
    #      DestinationPath = "$HOME\Draft.Zip"
    #      }
    #      Compress-Archive -Update @compress 
  







#   Compress-Archive -Path $rutaDelArchivo -Update -DestinationPath archive.zip


    # switch ($opcion)
    #    {
    #        "-l" { 
    #             #Listar el contenido de la papelera
    #             if( !(Listar-Papelera)  ) {
    #                 write-Host "Para mas ayuda utilice Get-Help"
    #                 exit
    #             }
    #             Break
    #         }

    #        "-e" {
    #             #Borrar el contenido de la papelera 
    #             if( !(Borrar-Papelera)  ) {
    #                 write-Host "Para mas ayuda utilice Get-Help"
    #                 exit
    #             }
    #             Break
    #         }
    #        "-r" {
    #             #Restaurar el archivo de la papelera, si existe
    #             if( !(Recuperar-Archivo($archivo))  ) {
    #                 write-Host "Para mas ayuda utilice Get-Help"
    #                 exit
    #             }
               
    #            Break
    #         }
    #    }
    
    #Si el primer parametro es un archivo, enviarlo a la papelera
    # if ( Test-Path $opcion -PathType Leaf) {
        
    #     if( !(Borrar-Archivo($archivo))  ) {
    #         write-Host "Para mas ayuda utilice Get-Help"
    #         exit
    #     }

    # } else {
    #     Write-Host "archivo $opcion no existe."
    #     write-Host "Para mas ayuda utilice Get-Help"
    #     return $false

    # }  

#    # Borrar-Archivo()

#     Write-Output "ESTO ES HOME:$HOME" 
#     Write-Output $Args[0]

#$rutaDelArchivo=Get-Childitem -Path C:\Users\Matias\Documents -Filter $Args[0] -Recurse

 #$rutaDelArchivo=Get-ChildItem -Path C:/home/* -Filter $archivo -Recurse | %{$_.FullName}  

# Write-Output $rutaDelArchivo

#Compress-Archive -Path "$rutaDelArchivo" -DestinationPath "$HOME/PapeleraEjercicio.zip"

# $compress = @{
#       LiteralPath= "$rutaDelArchivo"
#       CompressionLevel = "Fastest"
#       DestinationPath = "$HOME\Draft.Zip"
#       }
#       Compress-Archive -Update @compress 

# Compress-Archive -Path $rutaDelArchivo -Update -DestinationPath archive.zip

##########################LISTAR LOS ARCHIVOS DENTRO DEL ZIP###################################
#[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')


