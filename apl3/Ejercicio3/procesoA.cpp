#include <dirent.h>
#include <iostream>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <fstream>
#include <cstdlib>
#include <vector>
#include <iomanip>

using namespace std;

typedef struct {
	double resultAnio;
    int cantArchivos;
} mediaAnual;

void help()
{
    cout << "---------------------------------------------------------------------------------------" << endl;
    cout << "---------------------------------------------------------------------------------------" << endl;
    cout << "Se cuenta con un historico de facturacion, con este programa podra calcular la facturacion mensual, facturacion anual y facturacion media anual del anio que usted desee." << endl;
    cout << " - Para ello dispondra de las siguientes opciones en el menu:" << endl;
    cout << "\t - Facturacion mensual: Le solicitara el ingreso de anio y mes de Facturacion para obtener el total facturado" << endl;
    cout << "\t - Facturacion anual: Le solicitara el ingreso de un anio y obtendra el total facturado en el mismo" << endl;
    cout << "\t - Facturacion media anual: Le solicitara el ingreso de un anio y obtendra la Facturacion media del anio (operacion matematica = totalFacturado/mesesFacturadosEnElAnio)" << endl;
    cout << "Se debera ingresar de antemano la ruta donde se encuentran los directorios de fracturacion." << endl;
    cout << "---------------------------------------------------------------------------------------" << endl;
    cout << "---------------------------------------------------------------------------------------" << endl;
}

string convertToString(char* a, int size)
{
    int i;
    string s = "";
    for (i = 0; i < size; i++) {
        s = s + a[i];
    }
    return s;
}

string pideRutaFacturacion(void)
{
    string rutaFacturacion;
    cout << "Por favor, ingrese la ruta donde se encuentran los directorios de facturacion" << endl;
    getline(cin,rutaFacturacion);

    return rutaFacturacion;
}

double sumarFacturacion(string file)
{
    double x;
    double sum=0;
     ifstream inFile(file.c_str());
            if (!inFile)
            {
                cerr << "Unable to open file datafile.txt";
                exit(1);   // call system to stop
            }
            
            while (inFile>>x)
            {
                sum = sum + x;
            }

            inFile.close();
    return sum;
}



mediaAnual sumarFacturacionAnual(string path)
{
    string file;
    mediaAnual resultado;
    string pathaux=path;
    resultado.cantArchivos=0;
    resultado.resultAnio=0;

    if( DIR* pDIR = opendir(pathaux.c_str()) )
    {
        while(dirent* entry = readdir(pDIR))
        {
            resultado.cantArchivos++;
            std::string fileName = entry-> d_name;
            if( fileName != "." && fileName != ".." )
            {    file=path+"/"+fileName;
           resultado.resultAnio+=sumarFacturacion(file);
        }
        }
        closedir(pDIR);
    }
    cout<<std::fixed<<resultado.resultAnio<<endl;
    return resultado;
}

double resolverProblema (string datos[3],string path)
{
    mediaAnual res;
    double resultFinal=0;
    int opcion=0;
    string fileName=path+"/"+datos[2].c_str();

    stringstream opcionAux(datos[0]);
    opcionAux>>opcion;
    ifstream inFile;
    switch (opcion)
    {
    case 1:
        fileName=fileName+"/"+datos[1].c_str();
        resultFinal=sumarFacturacion(fileName);
        cout<<std::fixed<<std::setprecision(2)<<resultFinal <<endl;
        break;
    case 2:
        res=sumarFacturacionAnual(fileName);
        resultFinal=res.resultAnio;
        break;
    case 3:
        res=sumarFacturacionAnual(fileName);
        resultFinal=res.resultAnio/res.cantArchivos;
        break;

    default:
    cout<< "opcion incorrecta"<<endl;
        break;
    }

    return resultFinal;
}



int main(int argc, char *argv[])
{
string splitLines[3];
int i=0;

    if (argc != 1)
    {
        if (argc > 2)
        {
            cout << "La cantidad de parametros es incorrecta";
            return 1;
        }
        else if (!strcmp(argv[1],"--help") || !strcmp(argv[1], "-h"))
        {
            help();
            return 0;
        }
        else
        {
            cout << "El parametro ingresado es incorrecto";
            return 1;
        }
    }

    string ruta=pideRutaFacturacion();

    char *tuberia = "/tmp/tuberia";

    mkfifo(tuberia,0666);


        char contenido[50];//="1|enero|2021";

        int tuberiaAB = open("/tmp/tuberia", O_RDONLY);
        read(tuberiaAB,contenido,sizeof(contenido));
        close(tuberiaAB);
        int b_size = sizeof(contenido) / sizeof(char);

        string s_a = convertToString(contenido, b_size);
        string delimiter="|";
        vector<string> results;

        size_t pos = 0;
        std::string token;
while ((pos = s_a.find(delimiter)) != std::string::npos) {
    token = s_a.substr(0, pos);
    splitLines[i]=token;
    i++;
    s_a.erase(0, pos + delimiter.length());
}
splitLines[2]=s_a.substr(0,4);


string respuesta = to_string(resolverProblema(splitLines,ruta));

        tuberiaAB = open("/tmp/tuberia", O_WRONLY);
        write(tuberiaAB,respuesta.c_str(),strlen(respuesta.c_str())+1);
        close(tuberiaAB);

    return EXIT_SUCCESS;
}
