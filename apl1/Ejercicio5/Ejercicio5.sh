#!/bin/bash

# +++++++++++++++ENCABEZADO+++++++++++++++++++++++++++
# Nombre script: Ejercicio_5.sh
# Trabajo Práctico Nro. 1 (GRUPAL)
# Ejercicio: 5
# Integrantes:
  #  Cardozo Emanuel                    35000234
  #  Iorio Diego                        40730349
  #  Paz Zarate Evelyn  Jessica         37039295
  #  Perez Lucas Daniel                 39656325
  #  Ramos Marcos                       35896637
# Nro entrega: Segunda Entrega
# +++++++++++++++FIN ENCABEZADO+++++++++++++++++++++++

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
    echo -e "\nPARAMETROS:\n\t-n --notas: Directorio en el que se encuentran los archivos CSV."
    echo -e "\n\t-s --salida: Ruta del archivo JSON a generar (incluye nombre del archivo)."
    echo -e "\nEjemplo de ejecucion: ./ejercicio_5.sh lote_prueba  lote_prueba/actas.json" 
    echo -e "\nEjemplo de ejecucion: ./ejercicio_5.sh -n lote_prueba -s lote_prueba/actas.json" 
}

#Parametros de ayuda
if  [[ "$1" == "-?" ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]] 
then
    ayuda
    exit 1;
fi

#Validacion de cantidad de argumentos para saber si usa getopts o por posicion


if [[ "$#" -eq 4 ]]  
then

	ARGS=`getopt -q -o n:s: --long notas:,salida: -n 'parse-options' -- "$@"`
if [ $? != 0 ]
     then
	 echo "HOLA"
   	ayuda;
     exit 1;
fi

if [ $1 == $3 ] 
     then
     ayuda;
    exit 1;
 fi

 eval set -- "$ARGS"
 while true ; do 
     case "$1" in

#     -s | --salida ) ariaAt=$2 ; shift ; shift ;;
	 -n | --notas ) dirCsv="$2"
				echo $dirCsv
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
			fi ; shift ; shift ;;
#     -s | --salida ) etiquetas=$2; shift ; shift ;;
	-s | --salida ) salida="$2"
			dirSalida="${salida%/*}" #Extraigo el directorio de salida
			echo $dirSalida
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
			fi; shift ; shift ;;
    -- ) shift; break ;;
     * )  break ;;
     esac
	done

else
	#valido y asigno por posicion
	
	if [[ "$#" -ne 2 ]] 
	then
		echo -e "El numero de parametros ingresado es incorrecto"
		echo -e "$0 -? | -h | --help para ayuda"
		exit 0
	fi
	
	
	dirCsv=$1 

	salida=$2

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

	dirSalida="${salida%/*}" #Extraigo el directorio de salida
	
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

./sh/recolector_de_notas.sh $dirCsv
./sh/conversor_json.sh $salida
