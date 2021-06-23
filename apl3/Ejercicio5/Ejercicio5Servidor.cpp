#include <iostream>
#include <cstring>
#include <fstream>
#include <string>
#include <sstream>
#include <list>
#include <vector>
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
#include <sys/wait.h>
#include <semaphore.h>


#define LETRA 1
#define PALABRA 2
#define INTENTOS 6

using namespace std;
void handlerSigInt(int sig );
list<char>  compararConPalabraOculta(string,char * sendBuff ,int sizeBf,
const char* pElegida,char* palabraOculta,list<char>);
void help();
 void recorrerLisra(list<char> lista);
string listToString(list<char> lista);
void liberarRecursos();
void handlerSigSigusr1(int sig);

 sem_t *semBlockServer;
 

static int SIGUSR1_reciv = 0;

static int clienteJugando = 0;
static int finJuego=0;
 int socketComunicacion;


string elegirPalabra();

int main(int argc, char *argv[]){

    if (argc != 2 ) {
        cout << "La cantidad de parametros es incorrecta" << endl;
        return 1;
    }
    else if ( (!strcmp(argv[1],"--help") || !strcmp(argv[1], "-h"))) {
        help();
        return 0;
    }
    else if ( (atoi(argv[1])<=1023 ) ){
        cout << "El numero de puerto debe estar por encima de 1023 " << endl;
        return 0;
    }

    signal(SIGUSR1, handlerSigSigusr1);
    signal(SIGINT, SIG_IGN); //ignora ctrl+c

    // struct sigaction action;
    //  action.sa_handler = handlerSigInt;
    //  sigaction(SIGINT,&action,NULL);
      
    //Validacion//
    ///fin validacion//    

    semBlockServer = sem_open("bloqueoServer", O_CREAT, 0600, 1);

    int valorSem;
     sem_getvalue(semBlockServer, &valorSem);

     if (!valorSem)
     {
         cout << "Error,El servidor ya ha sido iniciado" << endl;
        return 0;
     }
     sem_wait(semBlockServer);





    //configuracion de server //
    struct sockaddr_in serverConfig;
    memset(&serverConfig, '0' , sizeof(serverConfig));
    serverConfig.sin_family = AF_INET;//127.0.0.1
    serverConfig.sin_addr.s_addr = htonl(INADDR_ANY);
    serverConfig.sin_port = htons(atoi(argv[1]));

    int socketEscucha = socket(AF_INET,SOCK_STREAM,0);
    bind (socketEscucha,(struct sockaddr*) &serverConfig,sizeof(serverConfig));

    listen(socketEscucha,1);
  
    while (!SIGUSR1_reciv)
    {   
            list<char>regLetras;
            finJuego = 0;
            cout << "Esperando Jugador....." << endl;
            socketComunicacion = accept(socketEscucha, (struct sockaddr *)NULL, NULL);
            cout << "Jugador conectado" << endl;
            clienteJugando =1;
            char sendBuff[2000];
            char readBuff[2000];
            int bytesRecibidos = 0;
          
        

        // string sendBuff;
            //snprintf(sendBuff,sizeof(sendBuff))
            string palabraElegida = elegirPalabra();
            cout<< "La palabra es : " << palabraElegida << endl;
            string mensaje ="";
            char palabraOculta[256];
            //string palabraOculta
            strcpy(palabraOculta,palabraElegida.c_str());

            char *ini = palabraOculta;
            ini++;
            while( *(ini+1) != '\0'){
            *ini = '_';
            ini++;
            }

        
        do{//aca
               
                 //ENVIO intentos
                snprintf(sendBuff,sizeof(sendBuff),"%d\n", (INTENTOS -finJuego));
                write(socketComunicacion,sendBuff,strlen(sendBuff) );
                //FIN ENVIO intentos
               
             

                    //LEO confirmacion para seguir
                bytesRecibidos = 0;
                bytesRecibidos = read (socketComunicacion,readBuff,sizeof(readBuff)-1 );
                readBuff[bytesRecibidos] = 0;
                //fin LEO confirmacion para seguir

                   //ENVIO PALABRA OCULTA
                snprintf(sendBuff,sizeof(sendBuff),"%s\n", palabraOculta);
                write(socketComunicacion,sendBuff,strlen(sendBuff) );
                //FIN ENVIO PALABRA OCULTA

                //RECIVO LETRA O PALABRA
                bytesRecibidos = 0;
                bytesRecibidos = read (socketComunicacion,readBuff,sizeof(readBuff)-1 );
                readBuff[bytesRecibidos] = 0;
                mensaje = string(readBuff);
                  if(mensaje != "DESCONECTADO\r\n" ){
               
                      cout << mensaje.size() << endl;
                cout<< "letra recivida : " << mensaje << endl;
                //FIN RECIVO LETRA O PALABRA
            
                //comparo la letra o palabra //
              regLetras= compararConPalabraOculta(mensaje,sendBuff,sizeof(sendBuff),palabraElegida.c_str(),palabraOculta,regLetras);
                            //le manda el resultado8si acerto o no)
                write(socketComunicacion,sendBuff,strlen(sendBuff));
              
                    recorrerLisra(regLetras);
                }else{
                           sem_post(semBlockServer);
                }
                
                //FIN comparo la letra o palabra //
                
                ///Termino la partida si adivine lapalabra
                 if(strcmp(palabraOculta,palabraElegida.c_str())==0){
                   finJuego = INTENTOS;
               }
                ///termino la partida si adivine la palabra
                
                //LEO confirmacion para seguir
                bytesRecibidos = 0;
                bytesRecibidos = read (socketComunicacion,readBuff,sizeof(readBuff)-1 );
                readBuff[bytesRecibidos] = 0;
                //fin LEO confirmacion para seguir
                
                //envia fin o  no fin
                if(strcmp(palabraOculta , palabraElegida.c_str()) != 0 ){
                    snprintf(sendBuff,sizeof(sendBuff),"%s\r\n", "NOFIN");
                }else
                {
                    snprintf(sendBuff,sizeof(sendBuff),"%s\r\n", "FIN");
                }
                
                if(finJuego == INTENTOS){
                    snprintf(sendBuff,sizeof(sendBuff),"%s\r\n", "FIN");
                }

                write(socketComunicacion,sendBuff,strlen(sendBuff));
                //FIN envia fin o  no fin

                //LEO confirmacion para seguir
                bytesRecibidos = 0;
                bytesRecibidos = read (socketComunicacion,readBuff,sizeof(readBuff)-1 );    
                readBuff[bytesRecibidos] = 0;
           
                //LEO confirmacion para seguir


        // } while( (strcmp(palabraOculta , palabraElegida.c_str()) != 0)  && (finJuego != INTENTOS) );
            } while( finJuego != INTENTOS  );

        //write

        if(strcmp(palabraOculta , palabraElegida.c_str()) == 0 )
        {
            snprintf(sendBuff,sizeof(sendBuff),"%s\r\n", "GANASTE");
        } 
        else
        {
            snprintf(sendBuff,sizeof(sendBuff),"%s\r\n", "PERDISTE");
        }
         write(socketComunicacion,sendBuff,strlen(sendBuff));

        //Read
         //LEO confirmacion para seguir
        bytesRecibidos = 0;
        bytesRecibidos = read (socketComunicacion,readBuff,sizeof(readBuff)-1 );    
        readBuff[bytesRecibidos] = 0;
    
        //LEO confirmacion para seguir


               //ENVIO PALABRA OCULTA
                snprintf(sendBuff,sizeof(sendBuff),"%s\n", palabraElegida.c_str());
                write(socketComunicacion,sendBuff,strlen(sendBuff) );
                //FIN ENVIO PALABRA OCULTA


            //Read
         //LEO confirmacion para seguir
        bytesRecibidos = 0;
        bytesRecibidos = read (socketComunicacion,readBuff,sizeof(readBuff)-1 );    
        readBuff[bytesRecibidos] = 0;
     
        //LEO confirmacion para seguir

        cout << "terminar" << endl;
        clienteJugando =0;
        close(socketComunicacion);
        sleep(1);
    }

    return EXIT_SUCCESS;


}


// string elegirPalabra(){
//     list <string> listaPalabras;
//     string palabra = "";
//     ifstream file("palabrasAhorcado.txt");
//     srand(time(NULL));
//     while (getline(file,palabra))
//     {
//         listaPalabras.push_front(palabra);
//     }
//     //int posPalabra = 0 + rand() % (listaPalabras.size()-1 +1-0)
//     vector <string> vectorPalabras(listaPalabras.size());
//     int posPalabra = 0 + rand() % (listaPalabras.size());
//     list <string>::iterator pos;
//     pos = listaPalabras.begin();
//     int i= 0;
//      while (pos != listaPalabras.end())
//      {
//          vectorPalabras.insert(vectorPalabras.begin(),*pos);
//          pos++;
//          i++;
//      }
     
//     palabra = vectorPalabras[posPalabra];
//    //cerar archivo
//    file.close();
//     return palabra;
// }


// void handlerSigInt(int sig ){

   
//      close(socketComunicacion);
//         sem_close(semBlockServer);
//     sem_unlink("bloqueoServer");
//      exit(sig);


// }

list<char> compararConPalabraOculta(string mensaje ,char * sendBuff ,int sizeBf,
const char* pElegida,char* palabraOculta,list<char> letras){

        bool coincidenciaPalabra = false;
    bool coincidenciaLetra = false;

     
    
        if(mensaje.size() == 1 ){
            const char  * l = mensaje.c_str();

            letras.push_back(*l);
            //letra
       
                while(*pElegida != '\0'){
                    if( *pElegida == *l  ){
                        coincidenciaLetra = true;
                        *palabraOculta = *l ;
                    }
                    palabraOculta++;
                    pElegida++;
                }   
            

            if(coincidenciaLetra==true )
           {
              
              cout<<"Letra correcta" << endl;
               snprintf(sendBuff,sizeBf,"%s\r\n", "letra correcta");
         
            }else{
                finJuego++;
                cout<<"Letra incorrecta" << endl;
               snprintf(sendBuff,sizeBf,"%s\r\n", "letra incorrecta");
            }
         //   return LETRA;
             
        }
        else 
        { //palabara
     
           if( strcmp(mensaje.c_str(),pElegida ) ==0)
                    {
                        coincidenciaPalabra =true;  
                        strcpy(palabraOculta ,pElegida);   
                    }

            if(coincidenciaPalabra==true)
            {   
                finJuego = INTENTOS;
                 cout<<"palabra correcta" << endl;
               snprintf(sendBuff,sizeBf,"%s\r\n", "palabra correcta");
               
            }else
            {
                finJuego++;
                cout<<"palabra incorrecta" << endl;
               snprintf(sendBuff,sizeBf,"%s\r\n", "palabra incorrecta");
            }
           //  return PALABRA;
            
        }


    //return 0;
    return letras;

}


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


void handlerSigInt(int sig ){

   
     close(socketComunicacion);
        sem_close(semBlockServer);
    sem_unlink("bloqueoServer");
     exit(sig);


}





void help()
{   
    cout << "-------------------------------------------------------" << endl;
    cout << "Descripción : El Script ejecuta servidor que estara esperando a que un " << endl;
    cout << "jugador se conecte para iniciar a jugar"<< endl;
    cout << "\t- Ayuda del Script   Ejercicio5Servidor ..." << endl;
    cout << "\t- Nombre Script:     ./Ejercicio5Servidor" << endl;
    cout << "\t- Ejemplo de uso:    ./Ejercicio5Servidor 5000 (nro de puerto mayor a 1023)" << endl;
    cout << "\t- Ejemplo de ayuda:    ./Ejercicio5Servidor -h"<< endl;
    cout << "\t- Ejemplo de ayuda:    ./Ejercicio5Servidor --help" << endl;
    cout << "\t- Fin de la ayuda... " << endl;
    cout << "-------------------------------------------------------" << endl;
 
}

void recorrerLisra(list<char> lista){
    
    list<char> :: iterator pos;
    pos = lista.begin();
      cout << "Las letras ingresadas son : ";
    while(pos!= lista.end()){
        cout<< *pos << " ";
        pos++;
    }   
    cout << endl;
}

 string listToString(list<char> lista){
    string historial="";
    list<char> :: iterator pos;
    pos = lista.begin();
    while(pos!= lista.end()){
        historial+= *pos;
        pos++;
    }   
return historial;

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
        close(socketComunicacion);
        sem_close(semBlockServer);
    sem_unlink("bloqueoServer");
 
}