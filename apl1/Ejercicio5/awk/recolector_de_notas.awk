function calculate_score(data){
    scores_length=split(data, array, ",")
    point_value=10/(scores_length-1)
    sum=0

    for(i=2;i<=scores_length;i++){
        sum+=(score_value[array[i]]*point_value)
    }

    return sum
}

function get_cod_materia(filename){
    path_length=split(filename, splited_path, "/")
    split(splited_path[path_length], splited_filename, "_")
    
    return splited_filename[1]
}

BEGIN	{
    FS=","
    score_value["b"]=1
    score_value["r"]=0.5
    score_value["m"]=0
}

{   
    cantidad_notas_por_dni[$1]++
    actas[$1, "materia", cantidad_notas_por_dni[$1]]=get_cod_materia(FILENAME)
    actas[$1, "notas", cantidad_notas_por_dni[$1]]=calculate_score($0)
}

END	{
    unset FS

    for(dni in cantidad_notas_por_dni){
        materia_y_nota=""

        for(i=1; i<=cantidad_notas_por_dni[dni]; i++){
            materia=actas[dni, "materia", i]
            nota=actas[dni, "notas", i]
            materia_y_nota=materia_y_nota","materia","nota
        }
        
        print dni""materia_y_nota
    }
}