score_value["b"]=1
score_value["r"]=0.5
score_value["m"]=0


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
    actas[NR]["dni"]=$1
    actas[NR]["materia"]="1112"
    actas[NR]["notas"]=calculate_score($0)
}

END	{
    unset FS

    for(i in actas) {
        print i" "actas[i]["dni"]" "actas[i]["notas"]
    }
}