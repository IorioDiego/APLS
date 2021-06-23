#include <iostream>
#include <unistd.h>
#include <string.h>
#include <algorithm>
#include <fcntl.h>

using namespace std;

void help()
{
    cout << "---------------------------------------------------------------------------------------" << endl;
    cout << "---------------------------------------------------------------------------------------" << endl;
    cout << "Se cuenta con un historico de facturacion, con este programa podra calcular la facturacion mensual, facturacion anual y facturacion media anual del a�o que usted desee." << endl;
    cout << " - Para ello dispondr� de las siguientes opciones en el menu:" << endl;
    cout << "\t - Facturaci�n mensual: Le solicitar� el ingreso de a�o y mes de facturaci�n para obtener el total facturado" << endl;
    cout << "\t - Facturaci�n anual: Le solicitar� el ingreso de un a�o y obtendr� el total facturado en el mismo" << endl;
    cout << "\t - Facturaci�n media anual: Le solicitar� el ingreso de un a�o y obtendr� la facturaci�n media del a�o (operaci�n matem�tica = totalFacturado/mesesFacturadosEnElA�o)" << endl;
    cout << "Se deber� ingresar de antemano la ruta donde se encuentran los directorios de fracturacion." << endl;
    cout << "---------------------------------------------------------------------------------------" << endl;
    cout << "---------------------------------------------------------------------------------------" << endl;
}

void menu(){
    cout << "---------------------------------------------------"           << endl;
    cout << "Seleccione una opcion:"                                        << endl;
    cout << "- 1.Facturacion mensual "                                      << endl;
    cout << "- 2.Facturacion anual"                                         << endl;
    cout << "- 3.Facturacion media anual"                                   << endl;
    cout << "- 4.Salir"                                                     << endl;
    cout << "---------------------------------------------------"           << endl;
}


int main(int argc, char *argv[]){
static int anio;
string mes_facturacion;
    if (argc != 1)
    {
        if (argc > 2) {
            cout << "La cantidad de parametros es incorrecta";
            return 1;
        }
        else if (!strcmp(argv[1],"--help") || !strcmp(argv[1], "-h")) {
            //help();
            return 0;
        }
        else {
            cout << "El parametro ingresado es incorrecto";
            return 1;
        }
    }

	menu();

   char opcion;
   opcion= getchar();

while(opcion!='4'){

switch(opcion) {
    case '1': //Facturación mensual
    cout << "Ingrese anio de facturacion:"           << endl;
    cin >> anio;
    cout << "Ingrese mes de facturacion:"           << endl;
    cin >> mes_facturacion;
    std::for_each(mes_facturacion.begin(), mes_facturacion.end(), [](char & c){
    c = ::tolower(c);
});
    break;
    case '2': //Facturación anual
    cout << "Ingrese anio de facturacion:"           << endl;
    cin >> anio;
    break;
    case '3': //Facturación media anual
    cout << "Ingrese anio de facturacion:"           << endl;
    cin >> anio;
    break;
    default:
    cout << "La opcion ingresada es incorrecta"      << endl;
}

if(opcion=='1'||opcion=='2'||opcion=='3')
{

    //INICIANDO LA CONEXION DE FIFO
            char respuesta[1000];
            std::string mensaje (1,opcion);
            mensaje=mensaje+"|"+mes_facturacion+"|"+std::to_string(anio);

            int fifoClienteServidor = open("/tmp/tuberia", 01);
            write(fifoClienteServidor,mensaje.c_str(),strlen(mensaje.c_str())+1);
            close(fifoClienteServidor);

            fifoClienteServidor = open("/tmp/tuberia", 00);
            read(fifoClienteServidor,respuesta,sizeof(respuesta));
            close(fifoClienteServidor);

            cout << "RESPUESTA: " << respuesta << endl;
            //FIN DE LA CONEXION

}
	opcion= getchar();

	menu();

    opcion= getchar();
}

    // signal(SIGUSR1,signal_handler);

    // mkfifo("/tmp/clienteServidor",0666);

    // while (1) {
    //     char contenido[1024];

    //     int fifoClienteServidor = open("/tmp/clienteServidor", O_RDONLY);
    //     read(fifoClienteServidor,contenido,sizeof(contenido));
    //     close(fifoClienteServidor);

    //     string respuesta = realizarAccion(string(contenido));

    //     fifoClienteServidor = open("/tmp/clienteServidor", O_WRONLY);
    //     write(fifoClienteServidor,respuesta.c_str(),strlen(respuesta.c_str())+1);
    //     close(fifoClienteServidor);
    // }

    return EXIT_SUCCESS;
}
