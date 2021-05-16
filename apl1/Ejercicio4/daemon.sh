#!/bin/bash

# +++++++++++++++ENCABEZADO+++++++++++++++++++++++++++
# Nombre script: daemon.sh
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

newStat=$(ls -la "$1" | wc -l)
newStat=$(( newStat - 1))
oldStat="$newStat"

while true
do
sleep 1
        if [[ "$oldStat" != "$newStat" ]]
        then
                IFS=$'\n'
                newFiles=($(ls -1a "$1"))
                for elem in ${newFiles[@]}
                do
                        echo "archivo :$elem"
                        primerCar=$(expr substr $elem 1 1)
                        if [ $primerCar == '.' ]
                        then
                                extension=$(echo $elem | awk -F . '{print $3}')
                        else
                        extension=$([[ "$elem" = *.* ]] && echo "${elem##*.}") 
                        fi
                                primerCar=$(expr substr $elem 1 1)
                                mkdir "$2/${extension^^}"
                                mv "$1/$elem" "$2/${extension^^}"                   
                        done
                     
                oldStat=$newStat
                unset IFS
        fi
newStat=$(ls -la "$1" | wc -l)
newStat=$(( newStat - 1))
done


