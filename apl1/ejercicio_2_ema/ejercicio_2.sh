#!/bin/bash


./helpers/handle_params.sh $@
corrected_file_name=$(./helpers/file_name_script.sh $2)
awk -f script_ej2.awk $2 > $corrected_file_name