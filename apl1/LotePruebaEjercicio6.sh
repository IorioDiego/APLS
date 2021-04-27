#!/bin/bash
userPath=$PWD

mkdir $userPath/Carpeta1
cd $userPath/Carpeta1
touch archivo1.txt
touch archivo2.sh

mkdir $userPath/Carpeta2
cd $userPath/Carpeta2
touch archivo3.txt
touch archivo1.txt

mkdir $userPath/Carpeta2/1
cd $userPath/Carpeta2/1
touch archivo3.txt
touch archivo1.txt
