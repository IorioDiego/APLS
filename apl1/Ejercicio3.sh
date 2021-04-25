#!/bin/bash

# +++++++++++++++ENCABEZADO+++++++++++++++++++++++++++
# Nombre script: Ejercicio3.sh
# Trabajo Práctico Nro. 1 (GRUPAL)
# Ejercicio: 3
# Integrantes:
    # 
    # 
    # 
    # 
    #
# Nro entrega: Primera Entrega
# +++++++++++++++FIN ENCABEZADO+++++++++++++++++++++++

recorrer_directorio()
{
 raiz=$(pwd)
 cd $1   
 dir=$(dir -1)
 
 for file in $dir
 do
  if [ -n "$file" ]; then
   if [ -d "$file" ];then
    if [ ! -r "$file" ];then
     echo "se intento acceder a un path sin permisos de lectura"
    exit 5
    fi
    #echo "DIR: " $file
    cd "$file"
    recorrer_directorio ./
    cd ..
   fi
   fi 
 done
}

function help(){

    echo "El script se encarga de eliminar los archivos duplicados (en su contenido) y genera un log con el nombre de estos archivos"
    echo "Para ello hace lo sigiente:"
    echo "Indicando un umbral y un directorio busca en el mismo los archivos duplicados y aquellos que superen el umbral antes mencionado."
    echo "Al finalizar realiza un informe que muestra estos archivos. Este informe se guardará en la ruta indicada por el usuario, en caso de no indicar ruta, se guardará en la misma carpeta de script."
    echo "----------------------------------------------------------------------------------------------"
    echo "SINTAXIS:"
    echo "./Ejercicio3.sh -Directorio [DIRECTORIO] -DirectorioSalida [DIRECTORIO DESTINO] -Umbral [UMBRAL]"
    echo "el orden de los parametros puede variar"
    echo "----------------------------------------------------------------------------------------------"

}

#Ayuda:
if [[ -z $1 || "$1" = "-h" || "$1" = "--help" ]] 
then
    help
    exit 0
fi

if [[ "$#" > 6 ]] 
then
    echo "El numero de parametros ingresado es incorrecto"
    exit 0
fi

for ARGS in "$@"; do
shift
        case "$ARGS" in
                "-Directorio") set -- "$@" "-d" ;;
                "-DirectorioSalida") set -- "$@" "-o" ;;
                "-Umbral") set -- "$@" "-u" ;;
                *) set -- "$@" "$ARGS"
        esac
done
output=''

while getopts "d:o:u:" option; do
  case $option in
    d ) directorio=$OPTARG
    echo "directorio: $directorio"
    echo -e "\n"
    ;;
    o ) output=$OPTARG
    echo "el directorio de salida es: $output"
    echo -e "\n"
    ;;
    u ) umbral=$OPTARG
    echo "El umbral ingresado es: $umbral"
    echo -e "\n"
    ;;
    *)
    echo "Usted ingresó un parametro incorrecto."
    echo -e "\n"
    exit 2
    ;;
    esac
done


IFS=$'\n'
auxdir="$(dirname "$(realpath $0)")"
recorrer_directorio $directorio
cd $auxdir

umbralBytes=$((umbral*1024))

echo  "Umbral: "$umbralBytes

if ! test -r "$output";then
   echo "se intento acceder a un path sin permisos de lectura"
   exit 5
fi

if ! test -w "$output";then
   echo "El directorio de salida no tiene permisos de escritura"
   exit 6
fi


if [[ ! "$(ls "$directorio")" ]]
then
    echo "el directorio está vacio"
    exit 7
fi


fieldListAux=($(readlink -e $(find $directorio -type f -print)))
fieldList=()
j=0

for ((i=0; i<${#fieldListAux[@]}; i++)){
    peso=$(ls -l ${fieldListAux[$i]} | awk '{print $5}')
    if [[ "$peso" -ge "$umbralBytes" ]]
    then
        fieldList[$j]=${fieldListAux[$i]}
        j=$((j+1))
    fi
}

for ((i=0; i<${#fieldList[@]}; i++)) 
do 
    for ((j=$((i+1)); j<${#fieldList[@]} ; j++)) 
    do 
        cmp -s "${fieldList[$i]}" "${fieldList[$j]}" && 

        #printf "%-50s\n " "$(basename ${fieldList[$i]})""${fieldList[$i]}""$(basename ${fieldList[$j]})""${fieldList[$j]}" #>> "aux.txt"
        echo "$(basename ${fieldList[$i]})"$'\t'$'\t'"${fieldList[$i]}"$'\n'"$(basename ${fieldList[$j]})"$'\t'$'\t'"${fieldList[$j]}" >> "aux.txt"
    done
done

sort aux.txt | uniq > "$output/resultado_{$(date +%Y-%0m-%0d_%k:%M:%S)}.txt"
rm aux.txt
