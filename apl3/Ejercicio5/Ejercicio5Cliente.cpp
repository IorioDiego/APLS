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
#include <sys/mman.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <signal.h>
#include <ctype.h>
#include <sys/wait.h>
#include <semaphore.h>

using namespace std;
void mostrarPalabra(char * );
void handlerSigInt(int sig );
void dibujarHangman(int);
 string  validarIngreso();
void hayJugadorActivo();
void help();
void enviarMsj(const char * mensaje);

 int socketComunicacion ;
sem_t *semBlockCliente;


int main(int argc, char *argv[]){

  
    if (argc < 2 || argc > 3) {
        cout << "La cantidad de parametros es incorrecta" << endl;
        return 1;
    }
    else if (argc == 2 && (!strcmp(argv[1],"--help") || !strcmp(argv[1], "-h"))) {
        help();
        return 0;
    }else if(argc == 2 && (strcmp(argv[1],"--help") || strcmp(argv[1], "-h"))){
        cout << "Parametros incorrectos" << endl;
        return 1;
    } else if (argc == 3 && (atoi(argv[2])<=1023 ) ) {
        cout << "El numero de puerto debe estar por encima de 1023 " << endl;
        return 0;
    }

    
    struct sigaction action;
     action.sa_handler = handlerSigInt;
     sigaction(SIGINT,&action,NULL);

    //Validacion//
    
    //fin validacion
 semBlockCliente = sem_open("bloqueoCliente", O_CREAT, 0600, 1);

    int valorSem;
       
 //
    sem_getvalue(semBlockCliente, &valorSem);
    if (!valorSem)
    {
        hayJugadorActivo();
        return 0;
    }

    sem_wait(semBlockCliente); //-->un solo cliente


    //configuracion de socket //
    struct sockaddr_in socketConfig;
    memset(&socketConfig, '0', sizeof(socketConfig));

    socketConfig.sin_family = AF_INET;
    socketConfig.sin_port = htons((atoi(argv[2])));
    inet_pton(AF_INET, argv[1], &socketConfig.sin_addr); 

    socketComunicacion = socket(AF_INET, SOCK_STREAM, 0);

    int resultadoConexion = connect(socketComunicacion,
        (struct sockaddr *)&socketConfig, sizeof(socketConfig));

        if(resultadoConexion < 0){
              sem_post(semBlockCliente);
            cout << "Error en la conexxion" << endl;
            return EXIT_FAILURE;
        }
         string ingreso;
        char sBuffer[2000];
        char rBuffer[2000];
        int bytesRecibidos = 0;

   
    
        do
        {//aca
             //system("clear"); 
            
            ////recibir cant intentos////
            bytesRecibidos = 0;
            bytesRecibidos = read (socketComunicacion,rBuffer,sizeof(rBuffer)-1 ); 
            rBuffer[bytesRecibidos] = 0;
            cout << "Intentos restantes : "<< rBuffer<< endl;
            char c = rBuffer[0];
  
            //// fin recibir cant intentos////
            dibujarHangman(atoi(&c));
            
             //envio confirmacion para que pueda seguir el server
            snprintf(sBuffer,sizeof(sBuffer),"%s\r\n", "OK");
             write(socketComunicacion,sBuffer,strlen(sBuffer));
            //fin envio confirmacion para que pueda seguir el server
            

            ////recibir palabra a adivinar////
            bytesRecibidos = 0;
            bytesRecibidos = read (socketComunicacion,rBuffer,sizeof(rBuffer)-1 ); 
            rBuffer[bytesRecibidos] = 0;
            mostrarPalabra(rBuffer);
            //// fin recibir palabra a adivinar////


             //// ingreso letra o palabra que pienso q es////
        
            cout<< "ingrese letra o palabra"<<endl;
            getline(cin, ingreso);

        //ingreso =   validarIngreso();
            
            snprintf(sBuffer,sizeof(sBuffer),"%s", ingreso.c_str());
            write(socketComunicacion,sBuffer,strlen(sBuffer));
             ////fin  ingreso letra o palabra que pienso q es////

            //recivo resultado(palbara o letra correcta) //
            bytesRecibidos = 0;
            bytesRecibidos = read (socketComunicacion,rBuffer,sizeof(rBuffer)-1 );
            rBuffer[bytesRecibidos] = 0;
       
            ////fin recivo resultado ///

            //envio confirmacion para que pueda seguir el server
            snprintf(sBuffer,sizeof(sBuffer),"%s\r\n", "OK");
            write(socketComunicacion,sBuffer,strlen(sBuffer));
            //fin envio confirmacion para que pueda seguir el server


            //lee si fue fin o no (si perdi o si adivine la palabra)    
            bytesRecibidos = 0;
            bytesRecibidos = read (socketComunicacion,rBuffer,sizeof(rBuffer)-1 );
            rBuffer[bytesRecibidos] = 0;
         
          
            // fin lee si fue fin o no (si perdi o si adivine la palabra)    

            //envio confirmacion para que pueda seguir el server
            snprintf(sBuffer,sizeof(sBuffer),"%s\r\n", "OK");
             write(socketComunicacion,sBuffer,strlen(sBuffer));
            //fin envio confirmacion para que pueda seguir el server

         

        }while ( strcmp(rBuffer,"FIN\r\n" ) != 0  );
              system("clear"); 
        //Read

         //lee si gane o perdi    
         bytesRecibidos = 0;
         bytesRecibidos = read (socketComunicacion,rBuffer,sizeof(rBuffer)-1 );
         rBuffer[bytesRecibidos] = 0;
     
        //fin lee si gane o perdi  

        if(strcmp(rBuffer,"PERDISTE\r\n")==0){
                dibujarHangman(0);
        }else
        {
            dibujarHangman(7);
        }

        //write
        //envio confirmacion para que pueda seguir el server
        snprintf(sBuffer,sizeof(sBuffer),"%s\r\n", "OK");
         write(socketComunicacion,sBuffer,strlen(sBuffer));
        //fin envio confirmacion para que pueda seguir el server


        ////recibir palabra a adivinar////
            bytesRecibidos = 0;
            bytesRecibidos = read (socketComunicacion,rBuffer,sizeof(rBuffer)-1 ); 
            rBuffer[bytesRecibidos] = 0;
            cout << "La palabra era : " << endl;
            mostrarPalabra(rBuffer);
            //// fin recibir palabra a adivinar////
    

        //write
        //envio confirmacion para que pueda seguir el server
        snprintf(sBuffer,sizeof(sBuffer),"%s\r\n", "OK");
         write(socketComunicacion,sBuffer,strlen(sBuffer));
        //fin envio confirmacion para que pueda seguir el server


        cout << "terminar" << endl;
        sem_post(semBlockCliente);
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
       sem_post(semBlockCliente);
     sem_close(semBlockCliente);
    sem_unlink("bloqueoCliente");
  

     enviarMsj("DESCONECTADO");
    //    enviarMsj("DESCONECTADO");
    //   enviarMsj("DESCONECTADO");
    //    enviarMsj("DESCONECTADO");
    //      enviarMsj("DESCONECTADO");
           close(socketComunicacion);

     exit(sig);
//12345

}

void enviarMsj(const char * mensaje){

    char sBuffer[2000];

    snprintf(sBuffer,sizeof(sBuffer),"%s\r\n", mensaje);
    write(socketComunicacion,sBuffer,strlen(sBuffer));

}

string  validarIngreso()
{
    int cont = 0;
    string ingreso;
    char ca = '\n';
    getline(cin, ingreso);
    if(ingreso.size() > 1){
        const char *ini = ingreso.c_str(); 
        while(*ini != '\0'){
            if(*ini=='\n'){
                cont ++;
   
            }
            ini++;
        }
    cout << "cantidad"<< cont <<endl;
    }
   // cout <<"HOLAAAAAAAa" << endl;
    return ingreso;
 
}

void hayJugadorActivo()
{
    cout << "Error,otro jugador se encuentra en la sala" << endl;
    cout << "Intente mas tarde" << endl;
}


void dibujarHangman(int n) {



        switch(n) 
        {
                    case 0:
                    {
                        cout<<endl<<endl 
                <<"   +----+     "<<endl 
                <<"   |    |     "<<endl 
                <<"   |    O     "<<endl 
                <<"   |   /|\\   "<<endl 
                <<"   |   / \\   "<<endl 
                <<"   | Moriste "<<endl 
                <<"  ============"<<endl<<endl; 
                    break;
                    } 

                    case 1:
                    {
                        cout<<endl<<endl 
                <<"   +----+  "<<endl 
                <<"   |    |  "<<endl 
                <<"   |    O  "<<endl 
                <<"   |   /|\\ "<<endl 
                <<"   |     \\ "<<endl 
                <<"   |       "<<endl 
                <<"  ============"<<endl<<endl; 
                    break;
                    }
                
                
                    case 2: 
                    {
                        cout<<endl<<endl 
                <<"   +----+  "<<endl 
                <<"   |    |  "<<endl 
                <<"   |    O  "<<endl 
                <<"   |   /|\\ "<<endl 
                <<"   |       "<<endl 
                <<"   |       "<<endl 
                <<"  ============"<<endl<<endl;         
                        break;
                    }
                
                    case 3: 
                    {
                        cout<<endl<<endl 
                <<"   +----+  "<<endl 
                <<"   |    |  "<<endl 
                <<"   |    O  "<<endl 
                <<"   |   /|  "<<endl 
                <<"   |       "<<endl 
                <<"   |       "<<endl 
                <<"  ============"<<endl<<endl; 
                    break;
                    }

                    
                    case 4:
                    {
                        cout<<endl<<endl 
                <<"   +----+  "<<endl 
                <<"   |    |  "<<endl 
                <<"   |    O  "<<endl 
                <<"   |    |  "<<endl 
                <<"   |       "<<endl 
                <<"   |       "<<endl 
                <<"  ============="<<endl<<endl; 
                    break;
                    }
                    

                    case 5:
                    {
                        cout<<endl<<endl 
                <<"   +----+  "<<endl 
                <<"   |    |  "<<endl 
                <<"   |    O  "<<endl 
                <<"   |       "<<endl 
                <<"   |       "<<endl 
                <<"  ============"<<endl<<endl; 
                        break;
                    }
                    

                    case 6:
                    {
                        cout<<endl<<endl 
                <<"   +----+  "<<endl 
                <<"   |    |  "<<endl 
                <<"   |       "<<endl 
                <<"   |       "<<endl 
                <<"   |       "<<endl 
                <<"   |       "<<endl 
                <<"  ============"<<endl<<endl; 
                break;
                    }

                case 7: {
                     cout<<endl<<endl 
                <<"   +----+     "<<endl 
                <<"   |    |     "<<endl 
                <<"   |          \\ O     "<<endl 
                <<"   |            | \\   "<<endl 
                <<"   |           / \\   "<<endl 
                <<"   | Sobreviviste "<<endl 
                <<"  ============"<<endl<<endl; 
                }



                }



               
}


void help()
{   
    cout << "-------------------------------------------------------" << endl;
    cout << "Descripción : El Script ejecuta el cliente que jugara al HangMan " << endl;
    cout << "conectandose al mismo puerto e IP que el servidor.Podra hacerlo" << endl;
    cout << "solo si hay un servidor conectado y si no hay otro jugador conectado" << endl;
    cout << "\t- Ayuda del Script   Ejercicio5Cliente..." << endl;
    cout << "\t- Nombre Script:     Ejercicio5Cliente 127.0.0.1 5000 "  << endl;
    cout << "\t- Ejemplo de uso:   ./Ejercicio5Cliente" << endl;
    cout << "\t- Ejemplo de ayuda:    ./Ejercicio4Servidor -h"<< endl;
    cout << "\t- Ejemplo de ayuda:    ./Ejercicio4Servidor --help" << endl;
    cout << "\t- Fin de la ayuda..." << endl;
    cout << "-------------------------------------------------------" << endl;
 
}