#!/bin/bash

# +++++++++++++++ENCABEZADO+++++++++++++++++++++++++++
# Nombre script: Ejercicio2.sh
# Trabajo Práctico Nro. 1 (GRUPAL)
# Ejercicio: 2
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
    echo "Se recibe un archivo de texto plano en el cual se corrigen los errores"
    echo "de puntuacion y de espaciado, al mismo tiempo se cuenta la ocurrencia"
    echo "de estos errores la cantidad de inconsistencias ( parentesis, signos de"
    echo "exclamacion y signos de interrogacion que se abran y nose cierren"
    echo "o viceversa"

    echo "-----------------------------Parametros-----------------------------"
    echo "-in path absoluto o relativo del archvivo que contiene el texto a analizar"
}

ErrorS(){
  
  echo "Error. La sintaxis es la siguiente: "
  echo "......: $0 -in archivo_texto_plano  "
}

rutaDeAchivo()
{
local PATH="$1"

  [[ "$PATH" = */* ]] && echo "${PATH%/*}" 
}

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]] || [[ "$1" == "-?" ]]
  then
      Help
      exit 0
fi

if [[ "$1" != "-in" ]]
  then
    ErrorS
    exit 1
fi

if ! [ -f "$2" ]
then
    echo "El archivo de entrada no existe"
    exit 1
fi

if ! [ -r "$2" ]
then
    echo "El archivo de entrada no tiene permiso de lectura"
    exit 1
fi

if ! [ -s "$2" ]
then
  echo "el archivo esta vacio"
  exit 1  
fi

 tipo="text/plain"
 tipoArch=$(file "$2" --mime-type)
 if [[ "$tipoArch" != *$tipo*  ]]
 then 
  echo "El archivo no es de texto plano"
   exit 1
 fi


# if ! [[ $(cat "$2") =~ ^.*$ ]]; then
# echo "NO texto plano"
# exit 1
# fi

echo "INCONCISTENCIAS" >>log.txt
erroesDeEspacio=$(grep -P -o '[ \t][ \t]+' "$2" | wc -l) 
echo "Errores de ESPACIADO: $erroesDeEspacio" >> log.txt
sed 's/\t/ /g; s/$/ /' "$2" > temp.txt  #reemplaza tabas por espacio y pone al final de cada linea un espacio

### cuenta los errores de COMA sin esapcio adelante ### 
caracterEspacio=$(grep -o -i ", " temp.txt | wc -l) 
caracter=$(grep -o -i "," temp.txt | wc -l) 
caracterEspacio=$(( caracter-caracterEspacio ))
if [[ caracterEspacio -lt 0 ]]
  then
    caracterEspacio=$(( caracterEspacio * (-1) ))
fi
echo "COMA sin espacio adelante: $caracterEspacio" >> log.txt

### cuenta los errores de COMA con esapcio atras### 
caracterEspacio=$(grep -o -i ' ,' temp.txt | wc -l ) 
echo "COMA con espacio atras: $caracterEspacio" >> log.txt

### cuenta los errores de PUNTO sin esapcio adelante ### 
caracterEspacio=$(grep -o "\. " temp.txt | wc -l) 
caracter=$(grep -o "\." temp.txt | wc -l) 
caracterEspacio=$(( caracter-caracterEspacio ))
if [[ caracterEspacio -lt 0 ]]
  then
    caracterEspacio=$(( caracterEspacio * (-1) ))
fi
echo "PUNTO sin espacio adelante: $caracterEspacio" >> log.txt

### cuenta los errores de PUNTO con esapcio atras### 
caracterEspacio=$(grep -o ' \.' temp.txt | wc -l ) 
echo "PUNTO con espacio atras: $caracterEspacio" >> log.txt

### cuenta los errores de PUNTO Y COMA sin esapcio adelante ### 
caracterEspacio=$(grep -o -i "; " temp.txt | wc -l) 
caracter=$(grep -o -i ";" temp.txt | wc -l) 
caracterEspacio=$(( caracter-caracterEspacio ))
if [[ caracterEspacio -lt 0 ]]
  then
    caracterEspacio=$(( caracterEspacio * (-1) ))
fi
echo "PUNTO Y COMA sin espacio adelante: $caracterEspacio" >> log.txt

### cuenta los errores de PUNTO Y COMA con esapcio atras### 
caracterEspacio=$(grep -o -i ' ;' temp.txt | wc -l ) 
echo "PUNTO Y COMA con espacio atras: $caracterEspacio" >> log.txt

### inconsistencias de  signo de pregunta###
apCaracter=$(grep -o -i '?' temp.txt | wc -l)
finCaracter=$(grep -o -i '¿' temp.txt | wc -l)
caracter=$(( apCaracter-finCaracter ))
if [[ caracter -lt 0 ]]
  then
    caracter=$(( caracter * (-1) ))
fi
echo "Signos de pregunta: $caracter" >> log.txt

### inconsistencias de signos de exclamacion###
apCaracter=$(grep -o -i '¡' temp.txt | wc -l)
finCaracter=$(grep -o -i '!' temp.txt | wc -l)
caracter=$(( apCaracter-finCaracter ))
if [[ caracter -lt 0 ]]
  then
    caracter=$(( caracter * (-1) ))
fi
echo "Signos de exclamacion: $caracter" >> log.txt

### inconsistencias de parentesis###
apCaracter=$(grep -o -i ')' temp.txt | wc -l)
finCaracter=$(grep -o -i '(' temp.txt | wc -l)
caracter=$(( apCaracter-finCaracter ))
if [[ caracter -lt 0 ]]
  then
    caracter=$(( caracter * (-1) ))
fi
echo "Parentesis: $caracter" >> log.txt
    ########coma######## ###punto y coma###  ######punto#######    
#####sed 's/,/, /g; s/ ,/,/g; s/;/; /g; s/ ;/;/g; s/\./. /g; s/ \././g; s/\t/ /g; s/ \+ / /g; s/^[ t]*//; s/[ t]*$//; /^$/d' "$2" > salida.txt #--> esto hace lo q pide la primera parte
 #sed 's/ ,/,/g; s/,/, /g; s/;/; /g; s/ ;/;/g; s/\./. /g; s/ \././g; s/\t/ /g; s/ \+ / /g; s/^[ t]*//; s/[ t]*$//; /^$/d' "$2" > salida.txt #--> esto hace lo q pide la primera parte
  sed 's/ \+ / /g; s/ ,/,/g;  s/,/, /g; s/ ;/;/g; s/;/; /g; s/ \././g; s/\./. /g;s/\t/ /g; s/ \+ / /g; s/^[ t]*//; s/[ t]*$//; /^$/d' temp.txt > salida.txt
  # reemplazando los espacios antes me evito q cuando reemplazo es el 
  #espacio caracter quede con mas espcios atras y cuando reemplace luego todos los espacios quede con uno solo atras, osea mal
  #uso el \. porq si no el puinto lo toma como cualqueir caracter
#grep -o -i '  ' $2 | wc -l

nombre="${2##*/}"   
nuevoNombre="$nombre_[$(date +%Y-%0m-%0d_%k:%M:%S)]"
ruta=$(rutaDeAchivo "$2")
extension=$([[ "$2" = *.* ]] && echo "${2##*.}") # con este obtengo la extension y tiene el caso de si tuviera mas de una
if [[ $extension == "" ]]
then
      mv "salida.txt" "$nuevoNombre" 
  
else
      mv "salida.txt" "$nuevoNombre.$extension" 
 
fi 

#mv salida.txt $ruta
#mv log.txt $ruta
rm temp.txt
#mv "salida.txt" "$nuevoNombre.$extension" 
mv "log.txt" "$nuevoNombre.log"