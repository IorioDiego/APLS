records_count=$(wc -l < data_temp.csv)
awk -f "./awk/jsonificador.awk" -v RC="$records_count" data_temp.csv > $1
rm data_temp.csv
