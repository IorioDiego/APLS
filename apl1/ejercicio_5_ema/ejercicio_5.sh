#!/bin/bash

for file in "$2/*"; do
    awk -f "parse_notes.awk" $file 
done > finales_semanales_temp.csv

awk -f "to_json.awk" finales_semanales_temp.csv > pepito.json