#Script que sirve para automatizar las compilaciones.
    #Una manera de compilar es primero crear el objeto: "g++ -c holamundo.cpp"
    #Luego creamos el ejecutable: "g++ -o holamundo.exe holamundo.o" (LINKEDICION)
    #Para hacerlo en un paso solo "g++ -o holamundo holamundo.cpp"
#Creamos las etiquetas que se compilaran a futuro.
all: procesoA procesoB

procesoA:
	rm -f procesoA
	g++ -o procesoA procesoA.cpp

procesoB:
	rm -f procesoB
	g++ -o procesoB procesoB.cpp

clear:
	rm -f procesoA
	rm -f procesoB