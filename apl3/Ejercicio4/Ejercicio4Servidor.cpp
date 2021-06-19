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
#define INTENTOS 6

using namespace std;

string elegirPalabra();
void help();
int solicitarLetraOPalabra(char *,const char*);
void liberarRecursos();
void handlerSigSigusr1(int);
void actualizarPalabraOculta();
void mostrarHistorial();
void reiniciarVariables();
//semaforos

sem_t *semEsperaCliente;
sem_t *semBlockServer;
sem_t *semEsperaIng;
sem_t *semFinJuego;
sem_t *semMostrar;
sem_t * semEsperaServer;
//semaforos

typedef struct {
    char letras[256];
    int lastPos=0;
    int cont=0;
}regLetras;

//shared memory
regLetras* shmLetras;
char *shmIng;
int * shmOpcion;
 char * shmOculta;
int cont=0; //???
int *shmGane; // 1 si 0 no
int *shmResult;
char * shmMensaje;
int  * shmRestantes;
int * shmInterrupcion;
//shared memory
static int SIGUSR1_reciv = 0;
static int finJuego = 0;
static int clienteJugando = 0;


 
int main(int argc, char const *argv[])
{   
    int valorSem;
    if (argc != 1)
    {
        
         if (!strcmp(argv[1], "--help") || !strcmp(argv[1], "-h"))
        {
            help();
            return 0;
        }else
        {
            cout <<"Parametros incorrectos"<< endl;
            help();
            exit(1);
        }
    }


    semEsperaCliente = sem_open("esperaCliente", O_CREAT, 0600, 0);
      semEsperaServer = sem_open("esperaServer", O_CREAT, 0600, 0);
    semEsperaIng = sem_open("esperaIng", O_CREAT, 0600, 0);
    semFinJuego = sem_open("finDeJuego", O_CREAT, 0600, 0);
    semMostrar = sem_open("mostrar", O_CREAT, 0600, 0);
     semBlockServer = sem_open("bloqueoServer", O_CREAT, 0600, 1);

    signal(SIGUSR1, handlerSigSigusr1);

   //sem_post(semBlockServer);

     sem_getvalue(semBlockServer, &valorSem);

     if (!valorSem)
     {
         cout << "Error,El servidor ya ha sido iniciado" << endl;
        return 0;
     }
     sem_wait(semBlockServer);

 
     string palabraElegida ;
//     int tam = palabraElegida.size();
//     char palabra [256]; // capaz puedo usar el tam de la palabra ; 
//    strcpy(palabra,palabraElegida.c_str());

    //SHARED MEMORY    
    int fd = shm_open("palabraOculta", O_CREAT | O_RDWR, 0600); //fileDescriptor
    ftruncate(fd, sizeof(char[256]));
    shmOculta = (char*)mmap(NULL, sizeof(char[256]), PROT_READ | PROT_WRITE,
        MAP_SHARED, fd, 0);
     close(fd);
     

     int fd2 = shm_open("opcion", O_CREAT | O_RDWR, 0600); //fileDescriptor
    ftruncate(fd2, sizeof(int));
    shmOpcion = (int*)mmap(NULL, sizeof(int), PROT_READ | PROT_WRITE,
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

    //FIN SHARED MEMORY  
    
      int resultado=0 ; 
     signal(SIGINT, SIG_IGN); //ignora ctrl+c
    while (!SIGUSR1_reciv)
    {
        //iniciarValores
         
         finJuego =0;
         palabraElegida = elegirPalabra();
          strcpy(shmOculta,palabraElegida.c_str());
        
        char *ini = shmOculta;
        ini++;
         while( *(ini+1) != '\0'){
        *ini = '_';
        ini++;
         }

        shmLetras->cont = 0;
        shmLetras->lastPos=0;
        *shmRestantes=INTENTOS;

        // fin iniciarvalores
        cout << "Esperando jugador..." << endl;
        sem_wait(semEsperaCliente);
        cout << "Jugador conectado" << endl;
         cout << "Palabra elegiada: " << palabraElegida << endl;
        clienteJugando=1;
        while (finJuego != INTENTOS)
        {
                 resultado = solicitarLetraOPalabra(shmOculta,palabraElegida.c_str());
            
            
                     switch (resultado)
                     { 
                            case LETRA ://1
                            {
                            //letra correcta
                                cout << "Letra ingresada : " << *shmIng <<endl;
                                mostrarHistorial();
                                cout << "Intentos restantes: "<< (INTENTOS - finJuego) << endl;  
                                if(strcmp(shmOculta,palabraElegida.c_str())==0 )
                                {
                                    finJuego=INTENTOS;;
                                    sem_post(semFinJuego);
                                } 
                                *shmResult=1;
                                 (*shmRestantes )= (INTENTOS - finJuego);
                              break;
                            }

                            case PALABRA:
                            {
                                    cout << "La palabra ingresada fue : "<< shmIng <<endl;
                                    
                                    mostrarHistorial();
                              
                                    *shmResult=1;
                                    finJuego=INTENTOS;;
                                    *shmRestantes = (INTENTOS - finJuego);
                                    sem_post(semFinJuego);
                                    
                                    break;
                             }
                            case 0:
                            {
                                finJuego++;
                                cout << "Letra o palabra incorrecta: "<< shmIng << endl;
                                mostrarHistorial();
                                cout << "Intentos restantes: "<< (INTENTOS - finJuego) << endl; 
                                *shmResult=0;
                                
                                 *shmRestantes = (INTENTOS - finJuego);
                                if (finJuego == INTENTOS)
                                {//haciendo q fin de juego aumento o no dentro de solicitar palabra puedo terminarlo si se equivoa de palabra
                                    *shmRestantes=0;
                                    sem_post(semFinJuego);
                                }
                               
                                break;                                
                            }

                            case 3:
                                {
                                    cout << "El jugador abandono la partida" <<endl;
                                    mostrarHistorial();
                                    sem_post(semFinJuego);
                                    finJuego=INTENTOS;
                                   //cout << "fin cuando abandona" <<finJuego << endl;
                                break;
                                }
                        
                          //  sem_post(semMostrar);//con este lo dejo al cliente mostrar el resultado
                     }
                    //  int valor;
                    //   sem_getvalue(semEsperaCliente, &valor);
                    //   cout << "valooor : " << valor<< endl;
            sem_post(semMostrar);
            sem_wait(semEsperaCliente);
        } 

        //finalizar partida
        if(resultado!=0) // si resultado es 2 quiere dcirq  gano si es 0 perdio hacer cosas en base a eso
        {
            if(resultado == 3){
                cout << "El jugador abandono la partida" <<endl;
            }else{
            *shmGane = 1;
                  cout <<"el jugador ha gando" << endl;
            }
            
                 
        }else 
        { 
            cout <<"el jugador ha perdido" << endl;
            *shmGane = 0;
        } 

        strcpy(shmOculta,palabraElegida.c_str());
        sem_post(semEsperaServer);
        sem_wait(semEsperaCliente);

        //      int valor;
        //               sem_getvalue(semEsperaCliente, &valor);
        //               cout << "valooor si llego : " << valor<< endl;
        //  cout <<"el LLEGUEEEEEEEEEEEEEE" << endl;
        
        
        sem_wait(semFinJuego); //vuelvo a poner en 0 el fin de juego
        reiniciarVariables();
         clienteJugando=0;
    }
    sem_post(semBlockServer);
    liberarRecursos();


}




void reiniciarVariables(){
    int valor ;

    //
    sem_getvalue(semEsperaCliente, &valor);
    while( valor != 0){
       // cout << "valor Espera cliente:" << valor << endl;
        sem_wait(semEsperaCliente);
    sem_getvalue(semEsperaCliente, &valor);
    }

      //
    sem_getvalue(semEsperaServer, &valor);
    while( valor != 0){
      //  cout << "valor Espera server:" << valor << endl;
        sem_wait(semEsperaServer);
    sem_getvalue(semEsperaServer, &valor);
    }

       //
    sem_getvalue(semEsperaIng, &valor);
    while( valor != 0){
       // cout << "valor Espera ingreso:" << valor << endl;
        sem_wait(semEsperaIng);
    sem_getvalue(semEsperaIng, &valor);
    }


//   sem_getvalue(semFinJuego, &valor);
//     while( valor != 0){
//         sem_wait(semFinJuego);
//     sem_getvalue(semFinJuego, &valor);
//     }

    //
    sem_getvalue(semMostrar, &valor);
    while( valor != 0){
       // cout << "valor mostrar:" << valor << endl;
        sem_wait(semMostrar);
    sem_getvalue(semMostrar, &valor);
    }
    
    *shmInterrupcion  =0;

}

void help()
{   
    cout << "-------------------------------------------------------" << endl;
    cout << "Descripción : El Script ejecuta servidor que estara esperando a que un " << endl;
    cout << "jugador se conecte para iniciar a jugar"<< endl;
    cout << "\t- Ayuda del Script   Ejercicio4Servidor ..." << endl;
    cout << "\t- Nombre Script:     ./Ejercicio4Servidor" << endl;
    cout << "\t- Ejemplo de uso:    ./Ejercicio4Servidor" << endl;
    cout << "\t- Ejemplo de ayuda:    ./Ejercicio4Servidor -h"<< endl;
    cout << "\t- Ejemplo de ayuda:    ./Ejercicio4Servidor --help" << endl;
    cout << "\t- Fin de la ayuda... " << endl;
    cout << "-------------------------------------------------------" << endl;
 
}

void mostrarHistorial(){

    cout << "Letras ingresadas" << endl;
   for(int i = 0; i<shmLetras->cont ; i++){
       cout << shmLetras->letras[i] <<  " ";
   }
   cout << endl;
}

void handlerSigSigusr1(int sig)//con 10 sirve
{

    if (SIGUSR1 == sig)
    {
        if (clienteJugando == 0)
        {
            cout << "Se recibio señal(" << sig << ")se interrumpira el proceso" << endl;
            liberarRecursos();
            exit(sig);
        }
        else
        {
            cout << "Se recibio señal(" << sig << ")se interrumpira el proceso" << endl;
            cout << "una vez finalizada la partida" << endl;
            SIGUSR1_reciv = 1;
        }
    }
}

void liberarRecursos()
{
        munmap(shmOculta,sizeof(char[256]));//despues pasar a liberar el recurso
       shm_unlink("palabraOculta");

    munmap(shmIng, sizeof(char[256]));
    shm_unlink("ing");
    munmap(shmOpcion, sizeof(int));
    shm_unlink("opcion");
    munmap(shmLetras, sizeof(regLetras));
    shm_unlink("registroLetras");
     munmap(shmGane, sizeof(int));
    shm_unlink("gane");

     munmap(shmResult, sizeof(int));
    shm_unlink("resultado");

    munmap(shmMensaje, sizeof(char[1000]));
    shm_unlink("mensaje");


    munmap(shmRestantes, sizeof(int));
    shm_unlink("restantes");

    munmap(shmInterrupcion, sizeof(int));
    shm_unlink("interrupcion");
  

  sem_close(semBlockServer);
    sem_unlink("bloqueoServer");

    sem_close(semFinJuego);
    sem_unlink("finDeJuego");
    sem_close(semEsperaCliente);
    sem_unlink("esperaCliente");
    sem_close(semBlockServer);
    sem_unlink("bloqueoServer");
    sem_close(semEsperaIng);
    sem_unlink("esperaIng");
    sem_close(semMostrar);
    sem_unlink("mostrar");
      sem_close(semEsperaServer);
    sem_unlink("esperaServer");



}

// void validarJugadorDesconectado(){
//     if( *shmInterrupcion == 1){

//     }
// }


string elegirPalabra(){
    list <string> listaPalabras;
    string palabra = "";
    ifstream file("palabrasAhorcado.txt");
    srand(time(NULL));
    while (getline(file,palabra))
    {
        listaPalabras.push_front(palabra);
    }
    //int posPalabra = 0 + rand() % (listaPalabras.size()-1 +1-0)
    vector <string> vectorPalabras(listaPalabras.size());
    int posPalabra = 0 + rand() % (listaPalabras.size());
    list <string>::iterator pos;
    pos = listaPalabras.begin();
    int i= 0;
     while (pos != listaPalabras.end())
     {
         vectorPalabras.insert(vectorPalabras.begin(),*pos);
         pos++;
         i++;
     }
     
    palabra = vectorPalabras[posPalabra];
   //cerar archivo
   file.close();
    return palabra;
}



int solicitarLetraOPalabra(char *palabraOculta,const char* pElegida){
    
    bool coincidenciaPalabra = false;
    bool coincidenciaLetra = false;
 //   sem_wait( semEsperaCliente);
    //sem_post();
  
     sem_wait(semEsperaIng);
            sem_wait(semEsperaIng);
   if(*shmInterrupcion == 0 ){ // el jugador no fue interrupido
           
            if( strlen(shmIng) == 1)
            {
                (shmLetras->cont)++;
                shmLetras->letras[shmLetras->lastPos]=*shmIng;
                (shmLetras->lastPos)++;
                while(*pElegida != '\0'){
                    if( *pElegida == *shmIng ){
                        coincidenciaLetra = true;
                        *palabraOculta = *shmIng;
                    }
                    palabraOculta++;
                    pElegida++;
                }

               
            }
             else
             {
                   

                    if( strcmp(shmIng,pElegida )==0)
                    {
                        coincidenciaPalabra =true;  
                        strcpy(palabraOculta ,pElegida);   
                    }
                   
             }
    if(coincidenciaLetra==true)
    {
        cout<<"Letra correcta" << endl;
        return LETRA;
    }

    if(coincidenciaPalabra==true){
        cout<<"Palabra correcta" << endl;
        return PALABRA;
    }
return 0;
}
else{
    return 3; //jguardor interrupido
} 

}