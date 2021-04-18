#!/bin/bash

# file_name= $(. file_name_script.sh $1)
corrected_file_name=$(./file_name_script.sh $1)
awk -f script_ej2.awk $1 > $corrected_file_name