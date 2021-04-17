#! /bin/bash

function get_file_name(){
    formated_date=$(date +"%Y%m%e%H%M")
    file_name="${1%.*}"
    file_extension="${1##*.}"
    
    echo "${file_name}_${formated_date}.${file_extension}"
}

get_file_name $1