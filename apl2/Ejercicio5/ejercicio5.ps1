# +++++++++++++++ENCABEZADO+++++++++++++++++++++++++++
# Nombre script: Ejercicio5.ps1
# Trabajo Práctico Nro. 2 (GRUPAL)
# Ejercicio: 5
# Integrantes:
  #  Cardozo Emanuel                    35000234
  #  Iorio Diego                        40730349
  #  Perez Lucas Daniel                 39656325
# Nro entrega: Segunda Entrega
# +++++++++++++++FIN ENCABEZADO+++++++++++++++++++++++

<#
    .SYNOPSIS
        Script para procesar las actas de finales rendidos por los alumnos
    .DESCRIPTION
        Se toma un directorio por parametro y se procesan los archivos CSV subidos 
        por el jefe de cátedra luego se obtiene on archivo json con todos los alumnos que rindieron el 
        final junto con las materias y la nota.
    .NOTES
        Los archivos CSV generado por el jefe de cátedra no poseen cabecera.
        El formato del nobre de los archivos es [CodMAteria]_yyyMMdd.csv
    .INPUTS
        -notas      [Ruta de la carpeta notas]
        -salida     [Ruta de la carpeta salida]/nombreJsonSalida.json
    .OUTPUTS
        [Ruta elegida]/nombreArch[.json]
        Archivo en formato Json con todas las notas de los finales rendidos 
        durante el periodo de tiempo fijado en el nombre de los archivos CSV
    .EXAMPLE
        ./ejercicio4.ps1 -notas [Ruta directorio notas] -salida [Ruta dir salida]/nombreJsonSalida.json
    .EXAMPLE
        ./ejercicio4.ps1 -salida [Ruta dir salida]/nombreJsonSalida.json -notas [Ruta directorio notas]
    
#>

Param
(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {
        if ( -Not (Test-Path $_ ) ) {
            throw "El directorio de notas no existe"
        }

        if ( -Not (Test-Path $_) ) {
            throw "El directorio de notas no existe"  
        }
        return $true;

    })]
    [string] $notas,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {
        # Directorio donde el usuario quiere guardar el archivo JSON
        $RUTA = split-path $_ 
        if($RUTA -eq ""){
        $RUTA= Get-Location
        }

        if ( -Not (Test-Path $RUTA) ) {
            throw "La ruta del archivo JSON no existe"
        }
        return $true
    })]
    [string] $salida
)


Import-Module -Force "./Funciones/Funciones.ps1"
Import-Module -Force "./Acta/Acta.ps1"
Import-Module -Force "./Materia/Materia.ps1"


<#
    Por parámetro se pasa la ruta junto con un archivo que todavía no se creó
    lo que hacemos es validar la extensión del archivo .json / .JSON
    Se puede guardar un Json econ cualquier extensión pero lo más logico 
    y que representa buenas prácticas es que se encuentre con una extensión .json
#>
if( !(validar-Extension -archivo $salida -extension ".json") ) {
    write-host "La extensión del archivo json es incorrecta"
    exit
} 


$actas=@{}

Get-ChildItem -Path $notas | ForEach-Object { 

    #Obtenso lolo el nombre del archivo con la extensión cortando la ruta
    $a=split-path $_ -leaf -resolve
    
    if( !(Validar-Extension -archivo $a -extension ".csv")  ) {
        write-Host "El archivo $a no posee la extensión correcta (CSV / csv)"
        exit
        # Los archivos csv tienen un formato en el nombre [COD_MATERIA]_yyyyMMdd.csv
    }elseif ( !(Validar-NombreCsv -archivo $_) ) {
        write-Host "El formato del nombre del archivo $a es erroneo consulte la ayuda"
        exit
    } 

     #Obtengo el codigo de la materia los primeros 4 caracteres del nombre del archivo
    $codMateria=($a -split "_")[0]

    # Genero la cabecera genérica para los CSV
    $HEADER=Gen-Header

    # Bandera utilizada para ayudar a la función Calcular-Campos
    # a solamente contar los campos de la primera fila dl archivo CSV
    $paso = $true
    
    Import-Csv -Path $_ -Header $HEADER | ForEach-Object {

        if ( $paso ) {
            # Calculo la cantidad de campos validos que tiene c/ fila del archivo 
            $cantidad = Calcular-Campos $_
            $paso = $false
        } 
        
        $dni = $_.dni
        
        #Retorna la nota del final rendido por el alumno _dni
        $notaFinal=Calcular-Notas -fila $_ -cantidad $cantidad

        #Esta condición verifica que el objeto a analizar y actualizar exista
        # Caso contrario genera uno nuevo
        if( $actas[$dni] -ne $null           -and 
            $actas.Count -ge 1               -and 
            $actas[$dni].dni.equals($dni) ) 
        {
            #Instancia de la clase Materia 
            #Ver ./Materia/Materia.ps1
            $m=[Materia]::new($codMateria,$notaFinal)

            $repetida=$false

            $actas[$dni].notas | ForEach-Object {
                #Recorre todo el listado de materias rendidas
                #Por un determinado Alumno.
                # Como las materias estan guardadas en formato JSON
                #Uso el cmd-let ConvertFrom-Json Para poder 
                #Comparar materias
                $_ | ConvertFrom-Json | ForEach-Object {
                    # Si esta materia esta repetida 
                    # Cambia el valor de la variable a true
                    if($_.materia.equals($m.materia)) { $repetida = $true }
                }
            }

            #Si repetida es falso entonces añade la materia 
            #dentro del arreglo de notas de la clase Acta
            #Ver ./Acta/Acta.ps1
            if( !($repetida) ) {
                # Guarda las materias en formato JSON
                $m = $m | ConvertTo-Json
                $actas[$dni].notas+=$m
            } else {
                write-host ""
                write-host ("El alumno {0} ya rindió la materia {1}" -f $dni, $m.materia)
                write-host ("Por lo tanto el exámen materia: {0} nota:{1} no serán cargadas en la salida" -f $m.materia, $m.nota)
                write-host ""
            }
        } else {
            <#
                En caso que la materia no se encuentre dentro de las 
                materias del alumno crea un Objeto Acta nuevo
                guardando la materia en un nuevo objeto
            #>
            $m=[Materia]::new($codMateria,$notaFinal)
            $m = $m | ConvertTo-Json 
            $acta = [Acta]::new()
            $acta.dni = $dni 
            $acta.notas += $m
            $actas[$dni] = $acta
        }
    }
}

#Genero la salida en el archivo JSON Ingresado 
#en los parámetros del ejercicio
Generar-Salida -actas $actas -salida $salida

Write-Host "El archivo $salida fue creado con exito"
