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

using namespace std;

string elegirPalabra();

int main(int argc, char *argv[]){

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
        int socketComunicacion = accept(socketEscucha, (struct sockaddr *)NULL, NULL);
        char sendBuff[2000];
        char readBuff[2000];
        int bytesRecibidos = 0;
         cout << "Hola"<< endl;
       // string sendBuff;
        //snprintf(sendBuff,sizeof(sendBuff))
        string palabraElegida = elegirPalabra();
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

       snprintf(sendBuff,sizeof(sendBuff),"%s", palabraOculta);
        write(socketComunicacion,palabraOculta.c_str(),strlen(palabraOculta.c_str());

       bytesRecibidos = read (socketComunicacion,readBuff,sizeof(readBuff)-1 );
        
         readBuff[bytesRecibidos] = 0;
        
    ///recibi letra o palabra // 
        mensaje = string(readBuff);
        cout<< mensaje << endl;


    //comparo la letra o palabra //

        if(mensaje.size() > 1 ){
            //palabra
            if(palabraElegida.find(mensaje) != string :: npos)
            {
                snprintf(sendBuff,sizeof(sendBuff),"%s", "palabra correcta\n");
                
            }else{
                     snprintf(sendBuff,sizeof(sendBuff),"%s", "palabra incorrecta\n");
            }

             
        }
        else
        { //letra
            if(palabraElegida.find(mensaje) != string :: npos)
            {
                snprintf(sendBuff,sizeof(sendBuff),"%s", "letra correcta\n");
                
            }else{
                     snprintf(sendBuff,sizeof(sendBuff),"%s", "letra incorrecta\n");
            }

            
        }
                 //le madna el resultado
     write(socketComunicacion,sendBuff,strlen(sendBuff));


    //envia fin o  no fin
    if(palabraOculta != palabraElegida){

       snprintf(sendBuff,sizeof(sendBuff),"%s", "NOFIN\n");
     
    }else
    {

       snprintf(sendBuff,sizeof(sendBuff),"%s", "FIN\n");
      
    }
   write(socketComunicacion,sendBuff,strlen(sendBuff));

    } while(palabraOculta != palabraElegida);
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