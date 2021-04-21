score_value["b"]=1
score_value["r"]=0.5
score_value["m"]=0

function json_field(key, value){
    return "\""key"\": "value
}

function calculate_score(data){
    scores_length=split(data, array, ",")
    point_value=10/scores_length
    sum=0

    for(i=2;i<=scores_length;i++){
        sum+=(score_value[array[i]]*point_value)
    }

    return sum
}

BEGIN	{
    FS=","
}

{   
    actas_field=json_field("actas", "[")
    dni_field=json_field("dni", "\""$1"\"")
    scores_field=json_field("notas", "[")
    
    subject_field=json_field("materia", "1112")
    score=calculate_score($0)
    score_field=json_field("nota", score)
    
    printf "{\n\
    %s\n\
    {\n\
        %s,\n\
        %s{\n\
            %s,\n\
            %s\n\
        }]\n\
    }]\n}", actas_field, dni_field, scores_field, subject_field, score_field
}

END	{
    unset FS
}