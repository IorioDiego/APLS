#!/bin/bash

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



if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]
  then
      Help
      exit 0
fi


if [[ $1 != "-in" ]]
  then
    ErrorS
    exit 1
fi



if ! [ -s $2 ] # pide ver si es texto plano pero no estoy seguro como hacerlo
then
  echo "el archivo esta vacio"
  exit 1  
fi

#cat /dev/null > log.txt esto de la manera q lo hago no es necesario, si estuviera escriebiedno mi 
# logs sobre el mismo archivo si lo encesito pra q lo borre




#tr -d '\n' < t.txt | sed 's/  / \n/g' | wc -l #--> me cuenta los doble espacios

#cat espacios.txt | tr "  " "\n" | tr -s "\n" | wc -l


 #erroesDeEspacio=$(sed 's/[ \t][ \t]+/ \n/g' $2 | wc -l)
#erroesDeEspacio=$(( $erroesDeEspacio - 1 ))
#echo $erroesDeEspacio
#echo "/// coma espacio "
#grep -o -i ", " $2  | wc -l
#grep -o -i "," $2  | wc -l
#echo "/// espacio coma "
#grep -o -i " ," $2  | wc -l
#grep -o -i "," $2  | wc -l 



echo "INCONCISTENCIAS" >>log.txt

### cuenta los errores de ESPACIOS Y TABS ###
#grep -E ' \t|  |\t ' $2 | sed 's/  / \n/g' | wc -l #--> cuenta espacio tabs o esapcios dobles o tabs espacio
erroesDeEspacio=$(grep -P -o '[ \t][ \t]+' $2 | wc -l) # you are the true king

echo "Errores de ESPACIADO: $erroesDeEspacio" >> log.txt
sed 's/\t/ /g; s/$/ /' $2 > temp.txt ##esto es para q no me cuente como el erroe l ultimo punto si notiene espacio adelante

#grep -E ' \t' $2 | sed 's/ \t/ \n/g' | wc -l
#grep -E '  ' $2 | sed 's/  / \n/g' | wc -l
#grep -E '\t ' $2 | sed 's/\t / \n/g' | wc -l
 
#la i sirve para hacerloc ase sensitice, no importa co lo signos
### cuenta los errores de COMA sin esapcio adelante ### 
caracterEspacio=$(grep -o -i ", " temp.txt | wc -l) #caso bueno
caracter=$(grep -o -i "," temp.txt | wc -l) #caso malo
caracterEspacio=$(( caracter-caracterEspacio ))
if [[ caracterEspacio -lt 0 ]]
  then
    caracterEspacio=$(( caracterEspacio * (-1) ))
fi
echo "COMA sin espacio adelante: $caracterEspacio" >> log.txt

### cuenta los errores de COMA con esapcio atras### 
caracterEspacio=$(grep -o -i ' ,' temp.txt | wc -l ) # solo necisitoeste caso para sacar los errores
echo "COMA con espacio atras: $caracterEspacio" >> log.txt

#grep '\.' $2
#grep '\. ' $2
### cuenta los errores de PUNTO sin esapcio adelante ### 
caracterEspacio=$(grep -o "\. " temp.txt | wc -l) #caso bueno
caracter=$(grep -o "\." temp.txt | wc -l) #caso malo
caracterEspacio=$(( caracter-caracterEspacio ))
if [[ caracterEspacio -lt 0 ]]
  then
    caracterEspacio=$(( caracterEspacio * (-1) ))
fi
echo "PUNTO sin espacio adelante: $caracterEspacio" >> log.txt

### cuenta los errores de PUNTO con esapcio atras### 
caracterEspacio=$(grep -o ' \.' temp.txt | wc -l ) # solo necisitoeste caso para sacar los errores
echo "PUNTO con espacio atras: $caracterEspacio" >> log.txt


### cuenta los errores de PUNTO Y COMA sin esapcio adelante ### 
caracterEspacio=$(grep -o -i "; " temp.txt | wc -l) #caso bueno
caracter=$(grep -o -i ";" temp.txt | wc -l) #caso malo
caracterEspacio=$(( caracter-caracterEspacio ))
if [[ caracterEspacio -lt 0 ]]
  then
    caracterEspacio=$(( caracterEspacio * (-1) ))
fi
echo "PUNTO Y COMA sin espacio adelante: $caracterEspacio" >> log.txt

### cuenta los errores de PUNTO Y COMA con esapcio atras### 
caracterEspacio=$(grep -o -i ' ;' temp.txt | wc -l ) # solo necisitoeste caso para sacar los errores
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
sed 's/,/, /g; s/ ,/,/g; s/;/; /g; s/ ;/;/g; s/\./. /g; s/ \././g; s/\t/ /g; s/ \+ / /g; s/^[ t]*//; s/[ t]*$//; /^$/d' $2 > salida.txt #--> esto hace lo q pide la primera parte
  #uso el \. porq si no el puinto lo toma como cualqueir caracter
#grep -o -i '  ' $2 | wc -l

nuevoNombre="accessibilityTest_{$(date +%Y-%0m-%0d_%k:%M:%S)}"
ruta=$(rutaDeAchivo $2)
extension=$([[ "$2" = *.* ]] && echo "${2##*.}") # con este obtengo la extension y tiene el caso de si tuviera mas de una
mv salida.txt $ruta
mv log.txt $ruta
rm temp.txt
#mv "$ruta/salida.txt" "$ruta/$nuevoNombre.$extension" 
#mv log.txt "$ruta/$nuevoNombre.log"







#nombre="${2##*/}"#
#echo "${nombre##*.}" # con este y el del arriba obtengo la extension


#tr -d '\n' < t.txt | sed 's/ ,/,\n/g' | wc -l


#sed 's/,/, /g; s/ ,/,/g; s/ \+ / /g' $2 > salida.txt --> esto hace lo q pide la primera parte

        #PARRA REEMPLAZAR ESPACIOS Y COMAS#
#sed 's/,/, /g' --> cambia "," por ", "
#sed 's/ ,/,/g' --> cambia  " ," por ","
#sed 's/ \+ / /g'--> cambia   los tabs y espacios en blanco por un espacio
#s/^[ t]*// -->elimina los tabs o espacios al principio de la linea
#s/[ t]*$// --> elimina los tabs o espaciso al final de la linea
#/^$/d' --> eliminar las lineas en blacno

        #Para contar cantidad de inconsistencias#
#grep -o -i '?' $2 | wc -l
#grep -o -i '¿' $2 | wc -l
# y restar esos valores , si queda negativo ponerlo positivo
# repetir para () y para ¡!

        #CONTAR OCURRENCIAS DE ", "
 #grep -o -i "," $2  | wc -l
#grep -o -i ", " $2  | wc -l
# cuentos y las resto

      #CONTAR OCURRENCIAS DE  " ,"
#tr -d '\n' < t.txt | sed 's/ ,/,\n/g' | wc -l  --> ambas lineas sirven para contar la ocurrencia de " ,"
#grep -o -i ' ,' $2 | wc -l                     --> ambas lineas sirven para contar la ocurrencia de " ," 
# cuentos y las resto




#sacar lineas en blanco y tabs y espacios creo --->   sed -i 's/^ //; s/ *$//; /^$/d; /^\s$/d; s/^\t*//; s/\t*$//;' fichero

#probar esto --> sed 's/ \+ /\t/g' inputfile > outputfile
 #o esto     --> sed 's/ */<TAB>/g' <spaces-file > tabs-file


 #si tengo 13 doble espavios seguidos, se considera 1 solo error o 13?