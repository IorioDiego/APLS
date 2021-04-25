records_count=$(wc -l < data_temp.csv)
awk -f "./awk/jsonificador.awk" -v RC="$records_count" data_temp.csv > actas.json
rm data_temp.csv