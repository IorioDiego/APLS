#!/bin/bash

for file in "$2/*"; do
    awk -f to_json.awk $file
done > pepito.json