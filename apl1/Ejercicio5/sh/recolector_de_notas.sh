for file in "$1/*"; do
    awk -f "./awk/recolector_de_notas.awk" $file 
done > data_temp.csv