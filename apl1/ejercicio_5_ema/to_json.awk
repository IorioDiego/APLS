BEGIN	{
    FS=","
    
    printf "{ \"actas\": [\n"
}

{   
    printf "{\n\t\"dni\": %s,\n\t\"notas\": [\n", $1

    for(i=2; i<NF; i+=2){
        printf "\t\t{ \"materia\": \"%s\", \"nota\": %s },\n", $i, $(i+1)
    }

    printf "\t]\n},\n"
}

END	{
    unset FS
    printf "] }"
}