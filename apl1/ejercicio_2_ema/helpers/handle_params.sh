case $1 in
    -h|--help) 
        printf "\
        El script se encarga de formatear el texto y generar un archivo de inconsistencias.\n\n\
        Opciones:\n\n\
            -in     Archivo de texto plano a formatear.\
        "
        exit 0
    ;;
    -in)
        if [[ $# -eq 1 ]] 
        then
            echo "Necesita ingresar el path al archivo"
            exit 1
        fi

        file_type=$(file -0 ${2} | cut -d $'\0' -f2)
        echo $(grep -E 'text|ASCII' "${file_type}")
        
        if [[ $file_type =~ !(text|ASCII) ]] 
        then
            echo "El archivo no es de texto plano."
            exit 2
        fi
    ;;
    *)
        echo "Parametros incorrectos. Para ayuda utilice el commando -h o --help"
        exit 1
    ;;
esac