BEGIN	{
    FS=","
    
    printf "{ \"actas\": [\n"
}

{   
    printf "\t{\n\t\t\"dni\": \"%s\",\n\t\t\"notas\": [\n", $1

    for(i=2; i<NF; i+=2){
        printf "\t\t\t{ \"materia\": %s, \"nota\": %s }", $i, $(i+1)
        
        if((i+1)<NF){
            printf ",\n"
        } else {
            printf "\n"
        }
    }

    if(NR<RC){
        printf "\t\t]\n\t},\n"
    } else {
        printf "\t\t]\n\t}\n"
    }
}

END	{
    unset FS
    printf "] }"
}
