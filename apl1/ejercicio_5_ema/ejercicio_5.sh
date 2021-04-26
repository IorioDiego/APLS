#!/bin/bash
#
# Nombre de Archivo: ejercicio5.sh
# APL: 1
# Ejercicio: 5
# Entrega: 1

# Modified: 18/04/2021

function ayuda()
{   
    echo ".....................................Descripcion:............................................"
    echo "El script consolida y procesa los ejercicios de un final para generar la notas  "
    echo "por comision para devolver actas en un unico archivo .json"
    echo "La cantidad de ejercicios puede variar en cada archivo csv por comision."
    echo "Cada archivo CSV representa una fecha de final, por lo tanto, tendrá las notas de todos los "
    echo "ejercicios de los alumnos que se presentaron a rendir. Los ausentes no están listados."
    echo ""
    echo "El script recibe obligatoriamente los siguientes parametros:"
    echo "\nPARAMETROS:\n\t-n --notas: Directorio en el que se encuentran los archivos CSV."
    echo "\n\t-s --salida: Ruta del archivo JSON a generar (incluye nombre del archivo)."
    echo -e "\nEjemplo de ejecucion: ./ej5.sh lote_prueba  lote_prueba/actas.json" 
    echo -e "\nEjemplo de ejecucion: ./ej5.sh -n lote_prueba -s lote_prueba/actas.json" 
}

#Parametros de ayuda
if  [[ "$1" == "-?" ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]] 
then
    ayuda
    exit 1;
fi

#Validacion de cantidad de argumentos para saber si usa getopts o por posicion

if [[ "$#" -eq 5 ]]  
then
    # Seteo variables con parametro enviados por argumento
	while getopts "n:s:" option; do
		case $option in
		n ) dirCsv="$OPTARG"
			if [[ ! -d $dirCsv ]]
			then
				echo "$dirCsv no existe o no es un directorio"
				echo -e "$0 -? | -h | --help para ayuda"
				exit 0
			fi
			
			if [[ ! -r $dirCsv ]]
			then
				echo "No tiene permisos de lectura para el directorio: $dirCsv"
				echo -e "$0 -? | -h | --help para ayuda"
				exit 0
			fi
		;;
		s ) salida="$OPTARG"
			dirSalida= "${salida##*/}" #Extraigo el directorio de salida
			if [[ ! -d $dirSalida ]]
			then
				echo "$dirSalida no existe o no es un directorio"
				echo -e "$0 -? | -h | --help para ayuda"
				exit 0
			fi
			
			if [[ ! -w $dirSalida ]]
			then
				echo "No tiene permisos de escritura para el directorio: $dirSalida"
				echo -e "$0 -? | -h | --help para ayuda"
				exit 0
			fi
		;;
		esac
	done


else
	#valido y asigno por posicion
	
	if [[ "$#" -ne 3 ]] 
	then
		echo -e "El numero de parametros ingresado es incorrecto"
		echo -e "$0 -? | -h | --help para ayuda"
		exit 0
	fi
	
	
	dirCsv = $1 

	salida = $2

	if [[ ! -d $dirCsv ]]
	then
		echo "$dirCsv no existe o no es un directorio"
		echo -e "$0 -? | -h | --help para ayuda"
		exit 0
	fi
	
	if [[ ! -r $dirCsv ]]
	then
		echo "No tiene permisos de lectura para el directorio: $dirCsv"
		echo -e "$0 -? | -h | --help para ayuda"
		exit 0
	fi

	dirSalida= "${salida##*/}" #Extraigo el directorio de salida
	if [[ ! -d $dirSalida ]]
	then
		echo "$dirSalida no existe o no es un directorio"
		echo -e "$0 -? | -h | --help para ayuda"
		exit 0
	fi
	
	if [[ ! -w $dirSalida ]]
	then
		echo "No tiene permisos de escritura para el directorio: $dirSalida"
		echo -e "$0 -? | -h | --help para ayuda"
		exit 0
	fi

fi

./sh/recolector_de_notas.sh $salida
./sh/conversor_json.sh
