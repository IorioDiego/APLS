#!/bin/bash

# +++++++++++++++ENCABEZADO+++++++++++++++++++++++++++
# Nombre script: Ejercicio4.sh
# Trabajo Práctico Nro. 1 (GRUPAL)
# Ejercicio: 4
# Integrantes:
  #  Cardozo Emanuel                    35000234
  #  Iorio Diego                        40730349
  #  Paz Zarate Evelyn  Jessica         37039295
  #  Perez Lucas Daniel                 39656325
  #  Ramos Marcos                       35896637
# Nro entrega: Primera Entrega
# +++++++++++++++FIN ENCABEZADO+++++++++++++++++++++++

Help(){
    echo "-----------------------------Descripcion-----------------------------"
    echo "El script mueve los archivos que se descarganen un directorio a otro"
    echo "de destino, para eso recive como parametro sun direcotrio a monitorear"
    echo "y otro donde seran enviados los archivos, en caso de no recivir este"
    echo "ultimo, los archivos, no se moveran de la carpeta de descargas"

    echo "-----------------------------Parametros-----------------------------"
    echo "-d path absoluto o relativo del direcotorio que se monitoreara -o path absoluto o relativo del direcotorio donde se enviaran los archivos"
    echo "-o path absoluto o relativo del direcotorio que se monitoreara -d path absoluto o relativo del direcotorio donde se enviaran los archivos"
    echo "-s indica que el demonio debe ser eliminado"
}


 
if [ $1 == $3 ] 
  then
    "Error de Sintaxis"
    Help
    exit 1;
fi

if [ "$1" == "-s" ] && [ $# -eq 1 ]
then
    killall daemon.sh >& /dev/null 
    echo "Se ha eliminado el demonio"
    exit 0
fi

if [[ "$3" == "-s" ]] || [[ "$5" == "-s" ]] 
then
    echo "no puede solicitar elimianar el demonio a  la vez que pasa la carpeta a monitorear y de destino"
    exit 0
fi


while getopts "d:o:s:h:?" option; do
  case $option in
    d ) descargas="$OPTARG"
    ;;
    o ) destino="$OPTARG"
    ;;
    h ) Help
        exit 0
    ;;
    ? ) Help
        exit 0
    ;;
    * ) Help
        exit 0
  esac
done

if [ -z "$destino" ] 
then
  destino="$descargas"
fi

if ! [ -d "$descargas" ] || ! [ -d "$destino" ] 
then
 echo "Uno de los directorios de entrada no existe"
 exit 1
fi 

if ! [ -w $destino ]
then
  echo "La carpeta de destino no tiene permiso de escritura"
  exit 1
fi

if ! [ -r $descargas ]
then
 echo  "La carpeta de descargas no tiene permiso de escritura"
  exit 1
fi
 
./daemon.sh >& /dev/null "$descargas" "$destino" & 
#./daemon.sh "$descargas" "$destino" &