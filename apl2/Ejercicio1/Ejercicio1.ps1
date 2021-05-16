[CmdletBinding()]
# Recibe 2 parámetros: valida que el primero sea un directorio y el segundo por defecto lo deja en 0.
Param (
 [Parameter(Position = 1, Mandatory = $false)]
 [ValidateScript( { Test-Path -PathType Container $_ } )]
 [String] $directorio,
 [Int] $limite = 0
)

# Listamos los directorios dentro del directorio de interés
$LIST = Get-ChildItem -Path $directorio -Directory
# Creamos un listado con el nombre y la cantidad de elementos dentro de él.
$ITEMS = ForEach ($ITEM in $LIST) {
 $COUNT = (Get-ChildItem -Path $ITEM).Length
 $props = @{
 name = $ITEM
 count = $COUNT
 }
 New-Object psobject -Property $props
}
# Ordenamos descendentemente, nos limitamos a los primeros N y nos quedamos con el nombre de cada uno
$CANDIDATES = $ITEMS | Sort-Object -Property count -Descending | Select-Object -First $limite | Select-Object -Property name

Write-Output "Top $limite directorios con más elementos:"
# Los mostramos en pantalla en forma de tabla
$CANDIDATES | Format-Table -HideTableHeaders

<#

1. ¿Cuál es el objetivo de este script?, ¿Qué parámetros recibe?, renombre los parámetros
con un nombre adecuado.

El objetivo del script es hacer un top de los N directorios con mas elementos. Siendo N un valor ingresado por parámetro. 
El script recibe 2 parámetros, la ruta y la cantidad de elementos máximos que desea que tenga la lista.

2. Comentar el código según la funcionalidad (no describa los comandos, indique la lógica)

3. Completar el Write-Output con el mensaje correspondiente.

4. ¿Agregaría alguna otra validación a los parámetros?, ¿existe algún error en el script?

Si, agregaría una validación sobre la cantidad de parámetros. No he detectado algún error.

5. ¿Para qué se utiliza [CmdletBinding()]?

Hace que nuestro script trabaje como un cmdlet compilado. Es decir, que tiene acceso a las características que tienen los cmdlets existentes.

6. Explique las diferencias entre los distintos tipos de comillas que se pueden utilizar en Shell
scripts.

Comillas simples '': se usa para valores literales. Ejemplo: "Hola $param" mostrará "Hola $param"
Comillas dobles "": se usa para valores literales y se sustituyen las referencias internas. Ejemplo: "Hola $param" mostrará "Hola mundo"
Comilla ` (backtick): se usa para prevenir las sustituciones a referencias internas. Ejemplo: "Hola `$param" mostrará "Hola $param"

7. ¿Qué sucede si se ejecuta el script sin ningún parámetro?

Se ejecuta el script como si se le hubiese pasado el directorio actual con un límite por defecto de 0.

#> 