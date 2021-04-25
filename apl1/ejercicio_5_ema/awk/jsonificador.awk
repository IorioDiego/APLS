BEGIN	{
    FS=","
    
    printf "{ \"actas\": [\n"
}

{   
    printf "\t{\n\t\t\"dni\": \"%s\",\n\t\t\"notas\": [\n", $1

    for(i=2; i<NF; i+=2){
        printf "\t\t\t{ \"materia\": %s, \"nota\": %s },\n", $i, $(i+1)
    }

    printf "\t\t]\n\t},\n"
}

END	{
    unset FS
    printf "] }"
}