#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <cstring>
#include <fstream>
#include <string>
#include <sstream>
#include <list>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <signal.h>

using namespace std;
void mostrarPalabra(char * );
void handlerSigInt(int sig );


 int socketComunicacion ;


int main(int argc, char *argv[]){


    struct sigaction action;
     action.sa_handler = handlerSigInt;
     sigaction(SIGINT,&action,NULL);

    //Validacion//
    

    //configuracion de socket //
    struct sockaddr_in socketConfig;
    memset(&socketConfig, '0', sizeof(socketConfig));

    socketConfig.sin_family = AF_INET;
    socketConfig.sin_port = htons(5000);
    inet_pton(AF_INET, argv[1], &socketConfig.sin_addr); 

    socketComunicacion = socket(AF_INET, SOCK_STREAM, 0);

    int resultadoConexion = connect(socketComunicacion,
        (struct sockaddr *)&socketConfig, sizeof(socketConfig));

        if(resultadoConexion < 0){
            cout << "Error en la conexxion" << endl;
            return EXIT_FAILURE;
        }
         string ingreso;
        char buffer[2000];
        int bytesRecibidos = 0;

   

    do
{
     bytesRecibidos = read (socketComunicacion,buffer,sizeof(buffer)-1 );

    buffer[bytesRecibidos] = 0;
     // printf("%s\n",buffer);
    
    //escribo palabra o letra
   mostrarPalabra(buffer);
    cout<< "ingrese letra o palabra"<<endl;
     getline(cin, ingreso);
   write(socketComunicacion,ingreso.c_str(),strlen(ingreso.c_str()));

    //recivo resultado
    bytesRecibidos = read (socketComunicacion,buffer,sizeof(buffer)-1 );
    buffer[bytesRecibidos] = 0;

    cout << buffer<< endl;

    //lee si fue fin o no
     bytesRecibidos = read (socketComunicacion,buffer,sizeof(buffer)-1 );
    buffer[bytesRecibidos] = 0;

    cout<<buffer<< endl;

}while ( strcmp(buffer,"FIN\n" ) != 0  );
 
cout << "terminar" << endl;
close(socketComunicacion);
return EXIT_SUCCESS;



}

void mostrarPalabra(char * p){

     while( (*p) != '\0'){
         cout << *p << " ";
         p++;
     }

     cout << endl << endl;

}

void handlerSigInt(int sig ){

   
     close(socketComunicacion);
     exit(sig);


}