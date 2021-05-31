# +++++++++++++++ENCABEZADO+++++++++++++++++++++++++++
# Nombre script: Ejercicio2.ps1
# Trabajo Práctico Nro. 2 (GRUPAL)
# Ejercicio: 2
# Integrantes:
  #  Cardozo Emanuel                    35000234
  #  Iorio Diego                        40730349
  #  Perez Lucas Daniel                 39656325
# Nro entrega: Segunda Entrega
# +++++++++++++++FIN ENCABEZADO+++++++++++++++++++++++


<#
    .SYNOPSIS
    Corrige y contabiliza errores de puntuación
    
    .DESCRIPTION
    A partir de un archivo de texto plano se analiza los errores (espacio.coma, punto, punto y coma con espacio adelante o atras) y las
    inconsistencias(paerentesis y signos de exclamacion y pregunta que abran pero no cierren o viceversa ) y luego se generan dos
    archivos de salido, uno LOG con la cuenta de los errores por categoria y un OUT con el texto que recido corregido

    .EXAMPLE
    ./punto2.ps1 --in archivo_a_analizar.txt

    .EXAMPLE
    ./punto2.ps1 Get-Help
#>


Param(

    [Parameter (Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {
            if ( -Not (Test-Path $_ )) {
                throw "El Path no existe"
            }
            if (-Not(Test-Path $_ -PathType Leaf)) {
                throw "El el path no es un archivo"
            }
            $FileInfo = Get-Content $_
            if ( -Not $FileInfo) {
                throw "El archivo de entrada esta vacio"
            }
          
            $tipo="${_}: text/plain"  
           $tipoArch=(file "$_" --mime-type)       
           if( "$tipoArch" -ne "$tipo" ) {
            throw "El archivo no es de texto plano"
           }

            return $true
        })]
    $in
)

# tipo="text/plain"
# tipoArch=$(file "$2" --mime-type)
# if [[ "$tipoArch" != *$tipo*  ]]
# then 
#  echo "El archivo no es de texto plano"
#   exit 1
# fi


$salida="salida.txt"
Set-Content -Value "ICONCISTENCIAS" -Path "log.txt" #borra lo q ya hay adentro
Get-Content "$in" | ForEach-Object {$_ -replace '\t+', '  '} | Set-Content $salida #reemplazos 1 tab por 2 espacios
$espacio=(Select-String -Path $salida -Pattern '[ \t][ \t]+' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern '[ \t][ \t]+' -AllMatches -Raw
$totalEspacio=($cadena -split '[ \t][ \t]+' ).count
$espacioFinal=($totalEspacio-$espacio) 
Add-Content -Value "Errores de ESPACIADO: $espacioFinal" -Path "log.txt" 

#paara evitar que cuente puntos de mas
Get-Content $salida | ForEach-Object {$_ -replace '$', ' '} | Set-Content $salida



#$coma=(Get-Content $in |Where-Object {$_ -match ','}).count
#$comaEspacio=(Get-Content $in |where {$_ -match ', '}).count
#$espacioComa=(Get-Content $in |where {$_ -match ' ,'}).count
            #COMA
$coma=(Select-String -Path $salida -Pattern ',' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern ',' -AllMatches -Raw
$totalComa=($cadena -split ",").count
$comasFinal=($totalComa-$coma) #total de comas


            #Espacio coma
$comaEspacio=(Select-String -Path $salida -Pattern ' ,' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern ' ,' -AllMatches -Raw
$totalComaEspacio=($cadena -split " ,").count
$comasEspacioFinal=($totalComaEspacio-$comaEspacio) #total de comas espacio
$errorC=$comasEspacioFinal
Add-Content -Value "COMA con espacio atras: $errorC" -Path "log.txt" 


            #COMA espacio
         
$espacioComa=(Select-String -Path $salida -Pattern ', ' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern ', ' -AllMatches -Raw
$totalEspacioComa=($cadena -split ", ").count
$espacioComaFinal=($totalEspacioComa-$espacioComa) #total de comas espacio
$errorC=($comasFinal-$espacioComaFinal)
Add-Content -Value "COMA sin espacio adelante: $errorC" -Path "log.txt" 

#-----------------------------------------------------------------------

            #pUNTO Y COMA
$caracter=(Select-String -Path $salida -Pattern ';' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern ';' -AllMatches -Raw
$totalCaracter=($cadena -split ";").count
$caracterFinal=($totalCaracter-$caracter) #total de comas

            #Espacio punto y coma 
      
$caracterEspacio=(Select-String -Path $salida -Pattern ' ;' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern ' ;' -AllMatches -Raw
$totalCaracterEspacio=($cadena -split " ;").count
$caracterEspacioFinal=($totalCaracterEspacio-$caracterEspacio) #total de comas espacio
$errorC=$caracterEspacioFinal
Add-Content -Value "PUNTO Y COMA con espacio atras: $errorC" -Path "log.txt" 


            #punto y coma ESPACIO 
         
$espacioCaracter=(Select-String -Path $salida -Pattern '; ' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern '; ' -AllMatches -Raw
$totalEspacioCaracter=($cadena -split "; ").count
$espacioCaracterFinal=($totalEspacioCaracter-$espacioCaracter) #total de comas espacio
$errorC=($caracterFinal-$espacioCaracterFinal)
Add-Content -Value "PUNTO Y COMA sin espacio adelante: $errorC" -Path "log.txt" 


#-----------------------------------------------------------------------------

            #pUNTO     
$caracter=(Select-String -Path $salida -Pattern '\.' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern '\.' -AllMatches -Raw
$totalCaracter=($cadena -split "\.").count
$caracterFinal=($totalCaracter-$caracter) #total de comas

            #Espacio punto y coma 
      
$caracterEspacio=(Select-String -Path $salida -Pattern ' \.' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern ' \.' -AllMatches -Raw
$totalCaracterEspacio=($cadena -split ' \.').count
$caracterEspacioFinal=($totalCaracterEspacio-$caracterEspacio) #total de comas espacio
$errorC=$caracterEspacioFinal
Add-Content -Value "PUNTO con espacio atras: $errorC" -Path "log.txt" 


            #punto y coma ESPACIO 
 #agregar espacio al final de cada linea para q no tome los puntos finales   como error        
$espacioCaracter=(Select-String -Path $salida -Pattern '\. ' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern '\. ' -AllMatches
$totalEspacioCaracter=($cadena -split '\. ').count
$espacioCaracterFinal=($totalEspacioCaracter-$espacioCaracter) #total de comas espacio
$errorC=($caracterFinal-$espacioCaracterFinal)
Add-Content -Value "PUNTO sin espacio adelante: $errorC" -Path "log.txt" 


#-----------------------------------------------------------------------------------
            #PREGUNTA 
$caracter=(Select-String -Path $salida -Pattern '¿' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern '¿' -AllMatches -Raw
$totalCaracter=($cadena -split '¿').count
$caracterFinalIni=($totalCaracter-$caracter) #total de comas

$caracter=(Select-String -Path $salida -Pattern '\?' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern '\?' -AllMatches -Raw
$totalCaracter=($cadena -split '\?').count
$caracterFinalFin=($totalCaracter-$caracter) #total de comas
$errorC= ($caracterFinalIni-$caracterFinalFin) 
if ($errorC -lt 0){
        $errorC=($errorC*(-1))
} 

Add-Content -Value "Signos de Pregunta: $errorC" -Path "log.txt" 

#-----------------------------------------------------------------------------------
        #EXCLAMACION
$caracter=(Select-String -Path $salida -Pattern '¡' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern '¡' -AllMatches -Raw
$totalCaracter=($cadena -split '¡').count
$caracterFinalIni=($totalCaracter-$caracter) #total de comas

$caracter=(Select-String -Path $salida -Pattern '!' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern '!' -AllMatches -Raw
$totalCaracter=($cadena -split '!').count
$caracterFinalFin=($totalCaracter-$caractgerter) #total de comas
$errorC= ($caracterFinalIni-$caracterFinalFin) 
if ($errorC -lt 0){
        $errorC=($errorC*(-1))
} 
Add-Content -Value "Signos de Exclamacion: $errorC" -Path "log.txt" 

#-----------------------------------------------------------------------------------
            #PARENTESIS
$caracter=(Select-String -Path $salida -Pattern '\(' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern '\(' -AllMatches -Raw
$totalCaracter=($cadena -split '\(').count
$caracterFinalIni=($totalCaracter-$caracter) #total de comas

$caracter=(Select-String -Path $salida -Pattern '\)' -AllMatches).count 
$cadena =Select-String -Path $salida -Pattern '\)' -AllMatches -Raw
$totalCaracter=($cadena -split '\)').count
$caracterFinalFin=($totalCaracter-$caracter) #total de comas
$errorC= ($caracterFinalIni-$caracterFinalFin) 
if ($errorC -lt 0){
        $errorC=($errorC*(-1))
} 
Add-Content -Value "Parentesis $errorC" -Path "log.txt" 

#necesito este y el de la linea 237 porq los reemplazos siguitenes agregar mas espacios
#entonces este limpia los tabs y espacios repetidos q vienen y el otro corrige lo q meten los 
#otros reemplazos
#elimina espacios y tabas al principio de la linea
Get-Content $salida | ForEach-Object {$_ -replace '[ \t]+', ' '} | Set-Content $salida

#saca espacios atras de la coma
Get-Content $salida | ForEach-Object {$_ -replace " ,", ","} | Set-Content $salida

#poner espacios adelante de la coma
Get-Content $salida | ForEach-Object {$_ -replace ",", ", "} | Set-Content $salida

#sacar espacios atras del punto y coma
Get-Content $salida| ForEach-Object {$_ -replace " ;", ";"} | Set-Content $salida

#poner espacios adelante del punto y coma
Get-Content $salida | ForEach-Object {$_ -replace ";", "; "} | Set-Content $salida


#sacar espacios atras del punto
Get-Content $salida | ForEach-Object {$_ -replace " \.", "."} | Set-Content $salida

#poner espacios adelante del punto
Get-Content $salida | ForEach-Object {$_ -replace "\.", ". "} | Set-Content $salida


#reemplaza tabs y espacios por un espacio
Get-Content $salida | ForEach-Object {$_ -replace '[ \t]+', ' '} | Set-Content $salida

#elimina espacios y tabas al principio de la linea
Get-Content $salida | ForEach-Object {$_ -replace '^[ \t]*', ''} | Set-Content $salida

#elimina espacios y tabas al final de la linea
Get-Content $salida | ForEach-Object {$_ -replace '[ \t]*$', ''} | Set-Content $salida

#elimina lineas en blanco
Get-Content $salida | ? {$_.trim() -ne ""} | Set-Content $salida 








$ruta=Split-Path -Path "$in"
$date = Get-Date -Format "yyyyMMddHHmmss" #"[yyyy-MM-dd_HH:mm]"
$nombre=[io.path]::GetFileNameWithoutExtension($in)
$extension=[io.path]::GetExtension($in)
$nuevoNombre="$($nombre)_$date"


if ($extension -eq "" ){
    Move-Item "salida.txt"  $ruta
    if($ruta -eq ""){
        Rename-Item -Path "salida.txt" -NewName "$nuevoNombre"
    }else {
        Rename-Item -Path "$ruta/salida.txt" -NewName "$nuevoNombre"
    }
   
  
}
else {
    Move-Item   "salida.txt"  $ruta
    if($ruta -eq ""){
        Rename-Item -Path "salida.txt" -NewName "$($nuevoNombre)$extension"
    }else {
        Rename-Item -Path "$ruta/salida.txt" -NewName "$($nuevoNombre)$extension"
    }
  
   
}
Move-Item   "log.txt" $ruta
if($ruta -eq ""){
    Rename-Item -Path "log.txt" -NewName "$nuevoNombre.log"
}else {
    Rename-Item -Path "$ruta/log.txt" -NewName "$nuevoNombre.log"
}






