#include <iostream>
#include <sched.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <semaphore.h>
#include <fcntl.h>
#include <string>
#include <signal.h>
#include <ios>
#include <list>
#include <fstream>
#include <cstdlib>
#include <time.h>
#include <vector>
 
#define PALABRA 2
#define LETRA 1


using namespace std;
//funciones

void hayJugadorActivo();
void help();
void ingresarLetra();
int jugar();
void liberarRecursos();
void mostrarPalabra(char * );
void mostrarResultado(char*);
void terminar(char*);
void handlerSigInt(int );
void dibujarHangman();
void mostrarHistorial();
//funciones


//semaforos
sem_t *semBlockServer;
sem_t * semEsperaCliente;
sem_t *semEsperaIng;
sem_t *semFinJuego;
sem_t *semBlockCliente;
sem_t* semMostrar;
sem_t* semEsperaServer;
//semaforos

typedef struct {
    char letras[256];
    int lastPos=0;
     int cont=0;
}regLetras;


//shared memory
int *shmOpcion;
char *shmIng;
regLetras *shmLetras;
int* shmGane;
int *shmResult;
char * shmMensaje;
int  * shmRestantes;
int * shmInterrupcion;
char * shmOculta ;
//shared memory








int main(int argc, char const *argv[])
{   
    int valorSem;
struct sigaction action;
     action.sa_handler = handlerSigInt;
     sigaction(SIGINT,&action,NULL);
    
   

    if (argc != 1)
    {
        
         if (!strcmp(argv[1], "--help") || !strcmp(argv[1], "-h"))
        {
            help();
            return 0;
        }
        else
        {
            cout <<"Parametros incorrectos"<< endl;
            help();
            exit(1);
        }
    }
    semBlockServer = sem_open("bloqueoServer", O_CREAT, 0600, 1);


   sem_getvalue(semBlockServer, &valorSem);
  
    if (valorSem)
    {
      cout<<"NO hay servidor al cual conectarse " <<endl;
        return 0;
    }
  
   semBlockCliente = sem_open("bloqueoCliente", O_CREAT, 0600, 1);
 // sem_post(semBlockCliente);
    sem_getvalue(semBlockCliente, &valorSem);
    if (!valorSem)
    {
        hayJugadorActivo();
        return 0;
    }

    sem_wait(semBlockCliente); //-->un solo cliente
 

    
    

    semEsperaCliente = sem_open("esperaCliente", O_CREAT, 0600, 0);
    semEsperaIng = sem_open("esperaIng", O_CREAT, 0600, 0);
    semFinJuego = sem_open("finDeJuego", O_CREAT, 0600, 0);
    semMostrar = sem_open("mostrar", O_CREAT, 0600, 0);
    semEsperaServer = sem_open("esperaServer", O_CREAT, 0600, 0);


    // struct sigaction action;
    // action.sa_handler = handlerSigInt;
    // sigaction(SIGINT,&action,NULL);



    int fd = shm_open("palabraOculta", O_CREAT | O_RDWR, 0600); //fileDescriptor
    ftruncate(fd, sizeof(char[256]));
     shmOculta = (char*)mmap(NULL, sizeof(char[256]), PROT_READ | PROT_WRITE,
        MAP_SHARED, fd, 0);
     close(fd);


     int fd2 = shm_open("opcion", O_CREAT | O_RDWR, 0600); //fileDescriptor
    ftruncate(fd2, sizeof(int));
    shmOpcion= (int*)mmap(NULL, sizeof(int), PROT_READ | PROT_WRITE,
        MAP_SHARED, fd2, 0);
     close(fd2);


     int fd3 = shm_open("ing", O_CREAT | O_RDWR, 0600); //fileDescriptor
    ftruncate(fd3, sizeof(char[256]));
     shmIng = (char*)mmap(NULL, sizeof(char[256]), PROT_READ | PROT_WRITE,
        MAP_SHARED, fd3, 0);
     close(fd3);

        int fd4 = shm_open("registroLetras", O_CREAT | O_RDWR, 0600); //fileDescriptor
    ftruncate(fd4, sizeof(regLetras));
    shmLetras = (regLetras*)mmap(NULL, sizeof(regLetras), PROT_READ | PROT_WRITE,
        MAP_SHARED, fd4, 0);
     close(fd4);

    int fd5 = shm_open("gane", O_CREAT | O_RDWR, 0600); //fileDescriptor
    ftruncate(fd5, sizeof(int));
    shmGane = (int*)mmap(NULL, sizeof(int), PROT_READ | PROT_WRITE,
        MAP_SHARED, fd5, 0);
     close(fd5);

    int fd6 = shm_open("resultado", O_CREAT | O_RDWR, 0600); //fileDescriptor
    ftruncate(fd6, sizeof(int));
    shmResult = (int*)mmap(NULL, sizeof(int), PROT_READ | PROT_WRITE,
        MAP_SHARED, fd6, 0);
     close(fd6);

      int fd7 = shm_open("mensaje", O_CREAT | O_RDWR, 0600); //fileDescriptor
    ftruncate(fd7, sizeof(int));
    shmMensaje = (char*)mmap(NULL, sizeof(char[1000]), PROT_READ | PROT_WRITE,
        MAP_SHARED, fd7, 0);
     close(fd7);

      int fd8 = shm_open("restantes", O_CREAT | O_RDWR, 0600); //fileDescriptor
    ftruncate(fd8, sizeof(int));
    shmRestantes = (int*)mmap(NULL, sizeof(int), PROT_READ | PROT_WRITE,
        MAP_SHARED, fd8, 0);
     close(fd8);




    int fd9 = shm_open("interrupcion", O_CREAT | O_RDWR, 0600); //fileDescriptor
    ftruncate(fd9, sizeof(int));
    shmInterrupcion = (int*)mmap(NULL, sizeof(int), PROT_READ | PROT_WRITE,
        MAP_SHARED, fd9, 0);
     close(fd9);


     sem_post(semEsperaCliente);
    dibujarHangman();
    cout<< "La palabra es : " << endl;
    
     mostrarPalabra(shmOculta);





    int finJuego;
    sem_getvalue(semFinJuego, &finJuego);

    while(!finJuego){
        jugar();
        sem_wait(semMostrar);
     system("clear"); 
        mostrarResultado(shmOculta);
            mostrarHistorial();
        sem_getvalue(semFinJuego, &finJuego);
        sem_post(semEsperaCliente);
    }
    system("clear"); 
        mostrarResultado(shmOculta);
     
    sem_wait(semEsperaServer);
    terminar(shmOculta);
    liberarRecursos();
        // munmap(shmOculta,sizeof(char[256]));
    //shm_unlink("palabraOculta");
   //  sem_post(semBlockCliente);
}

void help()
{   
    cout << "-------------------------------------------------------" << endl;
    cout << "Descripción : El Script ejecuta el cliente que jugara al HangMan " << endl;
    cout << "solo si hay un servidor conectado y si no hay otro jugador conectado" << endl;
    cout << "\t- Ayuda del Script   Ejercicio4Cliente..." << endl;
    cout << "\t- Nombre Script:     Ejercicio4Cliente" << endl;
    cout << "\t- Ejemplo de uso:   ./Ejercicio4Cliente" << endl;
    cout << "\t- Ejemplo de ayuda:    ./Ejercicio4Servidor -h"<< endl;
    cout << "\t- Ejemplo de ayuda:    ./Ejercicio4Servidor --help" << endl;
    cout << "\t- Fin de la ayuda..." << endl;
    cout << "-------------------------------------------------------" << endl;
 
}

void terminar(char *p){
    int f;
    if(*shmGane){
        cout << "Ganaste "  << endl;
    }else{
        cout<< "Perdiste" << endl;
    }
     sem_getvalue(semFinJuego, &f); //creo q no va
     cout << "La palbra era : ";
    mostrarPalabra(p);
   
    sem_post(semEsperaCliente);

}

void mostrarPalabra(char * p){

     while( (*p) != '\0'){
         cout << *p << " ";
         p++;
     }

     cout << endl << endl;

}

void mostrarHistorial(){
    cout << "Letras ingresadas : " ;
   for(int i = 0; i<shmLetras->cont ; i++){
       cout << shmLetras->letras[i] <<  " ";
   }
   cout << endl;
}

void hayJugadorActivo()
{
    cout << "Error,otro jugador se encuentra en la sala" << endl;
    cout << "Intente mas tarde" << endl;
}


int jugar(){
    int opcion=0 ;
    cout<< "Ingrese una palabra o una letra" << endl;
    cin.getline(shmIng,256);
    sem_post(semEsperaIng);
    sem_post(semEsperaIng);
    return 0;

}


void handlerSigInt(int sig ){

   
       *shmInterrupcion = 1;
       sem_post(semEsperaIng);
      sem_post(semEsperaIng);
       sem_post(semEsperaCliente);
       sem_post(semEsperaCliente);
       
    //   sem_close(semBlockCliente);
    //    sem_unlink("bloqueoCliente");
    liberarRecursos();
        exit(sig);
  
    //2 post de ing 
    //2 de espera cliente


}


void mostrarResultado(char * p)
{
    if(*shmResult == 1){//acerte
        
        if( strlen(shmIng) == 1)
        {
            cout  << "La letra ingresada esta dentro de la palabra" <<endl;
        }else
        {
            cout <<"Descubriste la palabra" << endl;
        }
    }
    else
    {
         if( strlen(shmIng) == 1)
         {

            cout  << "La letra ingresada es incorrecta"<< endl;
        }else
        {
            cout <<"La palabra es incorrecta" << endl;
        }
    }
    
    
    dibujarHangman();
    mostrarPalabra(p);
}

void dibujarHangman() {

    int valorFin ;
    sem_getvalue(semFinJuego, &valorFin);

    if( valorFin == 0 ){
        cout << "Intentos restantes : " << *shmRestantes << endl;
        switch(*shmRestantes) 
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
                
                 
                    
                }

    }
    else
    {

        if(*shmGane){
                    cout<<endl<<endl 
                <<"   +----+     "<<endl 
                <<"   |    |     "<<endl 
                <<"   |          \\ O     "<<endl 
                <<"   |            | \\   "<<endl 
                <<"   |           / \\   "<<endl 
                <<"   | Sobreviviste "<<endl 
                <<"  ============"<<endl<<endl; 

                       }
                       else
                       {
                  cout<<endl<<endl 
                <<"   +----+     "<<endl 
                <<"   |    |     "<<endl 
                <<"   |    O     "<<endl 
                <<"   |   /|\\   "<<endl 
                <<"   |   / \\   "<<endl 
                <<"   |  Moriste "<<endl 
                <<"  ============"<<endl<<endl; 
              
                    } 
        }
                    
}

void liberarRecursos()
{
 munmap(shmOculta,sizeof(char[256]));

    munmap(shmIng, sizeof(char[256]));
    

    munmap(shmOpcion, sizeof(int));
  

    munmap(shmLetras, sizeof(regLetras));
  

    munmap(shmGane, sizeof(int));
   

    munmap(shmResult, sizeof(int));


    munmap(shmMensaje, sizeof(char[1000]));

    munmap(shmRestantes, sizeof(int));

    munmap(shmInterrupcion, sizeof(int));

    sem_close(semBlockCliente);
    sem_unlink("bloqueoCliente");

}