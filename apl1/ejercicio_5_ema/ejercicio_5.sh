#!/bin/bash

awk -f "parse_notes.awk" $2 > pepito.json
# for file in "$2/*"; do
    
# done

# for file in "$2/*"; do
#     awk -f to_json.awk $file
# done > pepito.json