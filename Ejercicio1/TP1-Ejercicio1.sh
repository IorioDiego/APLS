# #!/bin/bash
# funcA() {
# echo "Error. La sintaxis del script es la siguiente:"
# echo "......................: $0 directorio 5" # COMPLETAR
# }
# funcB() {
# echo "Error. $1 ....................." # COMPLETAR
# }
# funcC() {
# if [[ ! -d $2 ]]; then
# funcB
# fi
# }
# funcC $# $1 $2 $3 $4 $5
# LIST=$(ls -d $1*/)
# ITEMS=()
# for d in $LIST; do
# ITEM="`ls $d | wc -l`-$d"
# ITEMS+=($ITEM)
# done
# IFS=$'\n' sorted=($(sort -rV -t '-' -k 1 <<<${ITEMS[*]}))
# CANDIDATES="${sorted[*]:0:$2}"
# unset IFS
# echo "....................." # COMPLETAR
# printf "%s\n" "$(cut -d '-' -f 2 <<<${CANDIDATES[*]})"



# 1.
# ¿Cuál es el objetivo de este script?, ¿Qué parámetros recibe?
# el objetivo del script es listar de forma ordenada los directorios dentro de algun directorio X que le pasemos por parametro
# se los ordena por cantidad de elementos que estos tengan, de mayor a menor.

# los parametros que recibe son 1 - directorio que se quiere analizar 
#                               2 - cantidad de resultados que se quieren obtener

# 2.
# Comentar el código según la funcionalidad (no describa los comandos, indique la lógica)
# Primero se valida si se ejecuto el script enviando los parametros necesarios y con la sintaxis correcta.
# Luego se crea un array con todos los directorios que hayan dentro del directorio que le hayamos pasado por parametro
# Estos se almacenan en otro array, donde se les asigna a los elementos un nuevo nombre concatenandoles previamente la cantidad de elementos que contengan (Ej: 5-/tmp/test/carpetaCon5Elementos/)
# A los elementos de este ultimo array se los ordena por numero de elementos de manera descendente
# Y finalmente se muestran cambiandoles el formato de salida. (Ej. /tmp/test/carpetaCon5Elementos/)

# 3.
# Completar los echo

# 4.
#   Cambiar nombre a las funciones
# funcA = mensajeSintaxisIncorrecta
# funcB = mensajeDirectorioInvalido
# funcC = validarParametros

# 5.
# ¿Agregaría alguna otra validación a los parámetros?, ¿existe algún error en el script?
# Si, agregariamos la validacion del segundo parametro, chequeando que sea un numero
# Se agrega una validacion al final del script para saber si hay datos para mostrar por pantalla
# Errores del script
# A la funcB (ahora es mensajeDirectorioInvalido) no se le habia asignado el parametro a utilizar 
# La funcC (ahora es validarParametros) contenia mas parametros que los necesarios



#!/bin/bash
mensajeSintaxisIncorrecta() { #Se indica al usuario la sintaxis correcta para poder ejecutar el script
echo "Error. La sintaxis del script es la siguiente:"
echo "1.Nombre del Fichero 2.Directorio a analizar 3.Cantidad de directorios que desea ver.  Por ejemplo: $0 directorio 5"
}
mensajeDirectorioInvalido() {
echo "Error. $1 debe ser un directorio válido."
}
validarParametros() { 
if [[ $1 < 2 ]]; then #Se valida que tenga al menos 2 parametros (se usa el $# pasado en la funcion validarParametros)
    mensajeSintaxisIncorrecta
elif [[ ! -d $2 ]]; then #Se valida que se haya pasado como 1er parametro un directorio (dentro de la funcion validarParametros es el 2do parametro) 
    mensajeDirectorioInvalido $2 #Se le agrega el $2
fi
}

validarParametros $# $1 $2 # $3 $4 $5 sobran
LIST=$(ls -d $1*/) #trae un listado de los directorios que hayan dentro del directorio indicado como parametro
ITEMS=()
for d in $LIST; do #Se recorre cada directorio
ITEM="`ls $d | wc -l`-$d" # accede al directorio $d y cuenta la cantidad de archivos que haya ahi. Quedando como formato ITEM = "20-/tmp/nombreDirectorio"
ITEMS+=($ITEM) #va agregando los elementos asi 20-/tmp/nombreDirectorio/, 5-/tmp/otro/
done
IFS=$'\n' sorted=($(sort -rV -t '-' -k 1 <<<${ITEMS[*]})) # -Se ordenan en base al numero obtenido anteriormente, de mayor a menor.
CANDIDATES="${sorted[*]:0:$2}"          #Se queda con la cantidad de elementos que se le hayan asignado por parametro
unset IFS
if [[ ${CANDIDATES[*]} > 0 ]]; then #Se agrega esta validacion para saber si hay elementos a mostrar
    echo "Directorios dentro de $1 con más elementos"
    printf "%s\n" "$(cut -d '-' -f 2 <<<${CANDIDATES[*]})"
fi


# 6.
# ¿Qué información brinda la variable $#? ¿Qué otras variables similares conocen?
# La variable $# informa la cantidad de parametros que se enviaron.

# Otras variables similares 
# $@ o $* : Listan todos los parametros enviados
# $$: Muestra el PID del proceso actual
# $!: Muestra el PID del proceso hijo ejecutado en segundo plano
# ?: Muestra el valor de ejecucion del último comando ejecutado. (0 si salio bien, 1 si salio mal)
# PWD: Muestra la ruta en la que estamos parados actualmente


# 7.
# Explique las diferencias entre los distintos tipos de comillas que se pueden utilizar en Shell scripts
# Las comillas simples '' : se utilizan para referirse a valores literales. 
# Por ejemplo 'hola $nombre'. Mostrara por pantalla literalmente hola $nombre

# Las comillas dobles "": se utilizan para poder sustiruir lo que haya dentro de una referencia. 
# Por ejemplo "hola $nombre". Mostrará por pantalla lo que haya en la variable nombre. hola Juan 

# Las comillas invertidas ``: se utilizan para guardar el valor que devuelvan los comandos
# Por ejemplo listado = `ls /tmp/test | wc -l` ejecutará los camando entre `` y usará lo devuelto en la variable listado

# 8.
# ¿Qué sucede si se ejecuta el script sin ningún parámetro?
# En ese caso llamará a la funcion de validacion validarParametros, 
# donde se le indicará al usuario la sintaxis correcta para poder ejecutar el script.