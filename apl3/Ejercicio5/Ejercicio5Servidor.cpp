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
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <signal.h>

#define LETRA 1
#define PALABRA 2

using namespace std;
void handlerSigInt(int sig );
int compararConPalabraOculta(string,char * sendBuff ,int sizeBf,
const char* pElegida,char* palabraOculta);
 
 
 
 int socketComunicacion;


string elegirPalabra();

int main(int argc, char *argv[]){

    struct sigaction action;
     action.sa_handler = handlerSigInt;
     sigaction(SIGINT,&action,NULL);


    //Validacion//
    

    //configuracion de server //
    struct sockaddr_in serverConfig;
    memset(&serverConfig, '0' , sizeof(serverConfig));
    serverConfig.sin_family = AF_INET;//127.0.0.1
    serverConfig.sin_addr.s_addr = htonl(INADDR_ANY);
    serverConfig.sin_port = htons(5000);

    int socketEscucha = socket(AF_INET,SOCK_STREAM,0);
    bind (socketEscucha,(struct sockaddr*) &serverConfig,sizeof(serverConfig));

    listen(socketEscucha,1);
  
    while (true)
    { 
            socketComunicacion = accept(socketEscucha, (struct sockaddr *)NULL, NULL);
            char sendBuff[2000];
            char readBuff[2000];
            int bytesRecibidos = 0;
            cout << "Hola"<< endl;
        

        // string sendBuff;
            //snprintf(sendBuff,sizeof(sendBuff))
            string palabraElegida = elegirPalabra();
            cout<< "La palabra es : " << palabraElegida << endl;
            string mensaje;
            char palabraOculta[256];
            //string palabraOculta
            strcpy(palabraOculta,palabraElegida.c_str());

            char *ini = palabraOculta;
            ini++;
            while( *(ini+1) != '\0'){
            *ini = '_';
            ini++;
            }

        
        do{
                    //ENVIO PALABRA OCULTA

                snprintf(sendBuff,sizeof(sendBuff),"%s\n", palabraOculta);
                    write(socketComunicacion,sendBuff,strlen(sendBuff) );

            //RECIVO LETRA O PALABRA
                bytesRecibidos = read (socketComunicacion,readBuff,sizeof(readBuff)-1 );
                    
                    readBuff[bytesRecibidos] = 0;
                    
                ///recibi letra o palabra // 
                    mensaje = string(readBuff);
                    cout<< mensaje << endl;

            
                //comparo la letra o palabra //
                 compararConPalabraOculta(mensaje,sendBuff,sizeof(sendBuff),palabraElegida.c_str(),palabraOculta);
                
                            //le manda el resultado
                write(socketComunicacion,sendBuff,strlen(sendBuff));


                //envia fin o  no fin
                if(strcmp(palabraOculta , palabraElegida.c_str()) != 0 ){

                snprintf(sendBuff,sizeof(sendBuff),"%s\n", "NOFIN");
                
                }else
                {

                snprintf(sendBuff,sizeof(sendBuff),"%s\n", "FIN");
                
                }
                write(socketComunicacion,sendBuff,strlen(sendBuff));

        } while( strcmp(palabraOculta , palabraElegida.c_str()) != 0 );


        close(socketComunicacion);
        sleep(1);
    }

    return EXIT_SUCCESS;


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
     exit(sig);


}

int compararConPalabraOculta(string mensaje ,char * sendBuff ,int sizeBf,
const char* pElegida,char* palabraOculta){

        bool coincidenciaPalabra = false;
    bool coincidenciaLetra = false;

        
        cout<< mensaje << endl;
        if(mensaje.size() == 1 ){
            const char  * l = mensaje.c_str();


            //letra
           cout << "letra : " << *l  << endl;
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
               snprintf(sendBuff,sizeBf,"%s", "letra correcta\n");
         
            }else{
                cout<<"Letra incorrecta" << endl;
               snprintf(sendBuff,sizeBf,"%s", "letra incorrecta\n");
            }
            return LETRA;
             
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
                 cout<<"palabra correcta" << endl;
               snprintf(sendBuff,sizeBf,"%s", "palabra correcta\n");
               
            }else
            {
                cout<<"palabra incorrecta" << endl;
               snprintf(sendBuff,sizeBf,"%s", "palabra incorrecta\n");
            }
             return PALABRA;
            
        }


    return 0;

}