#include <iostream>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <signal.h>
#include <thread>
#include <ctime>
#include <string.h>
#include <regex>

#define MAXVAL 1000
#define TODO_OK 1
#define ERROR 0
#define OVERFLOW -1

using namespace std;
/*
 * Desarrollar un programa que reciba 
 * por parámetro un número N 
 * (cantidad de iteraciones) y un número
 * P (nivel de paralelismo).
*/
int M = 2; // variable global

void Hilo(int idThread, int *acum, int n)
{
    unsigned t0, t1; // controlan el tiempo por ciclo
    double timeCiclo;
    t0=clock();
    for(int i = 0; i < n; i++)
    {
        //printf("Thread %d opera sobre el numero %d.\n", idThread, M);
        *acum *= M;
        *acum += *acum;
        *acum /= 2;     
    }
    t1=clock();
    timeCiclo = (double(t1-t0)/CLOCKS_PER_SEC);
    cout <<  "Para M = " << M << " --> "<< "Execution Time: " << timeCiclo << endl;
    

}


int main(int argc, char *argv[])
{
    /******************************* VALIDACIONES ****************************************************/



    if(argc == 2){

                if( strcasecmp(argv[1], "--help") == 0 || strcmp(argv[1], "-h") == 0 || strcasecmp(argv[1], "-?") == 0 ){
            cout << "\033[1;32m_______________________________________________________________________\033[0m\n"<<endl;
            cout << "\033[1;32mEjercicio 2: Threads \033[0m\n" << endl;
            cout << "\033[1;32mEl script recibe como parametro:)\033[0m\n" << endl;
            cout << "\033[1;32m-N (Entero Positivo, cantidad de iteraciones)\033[0m\n" << endl;
            cout << "\033[1;32m-P (Entero Positivo, grado de paralelismo)\033[0m\n" << endl;
            cout << endl;
            cout << "\033[1;32m.Ejemplo:\033[0m\n" << endl;
            cout << "\033[1;32m./ejercicio2 2 2\033[0m\n" << endl;
            cout << endl;
            cout << "\033[1;32m________________________________________________________________________\033[0m\n" << endl;
            return TODO_OK;
        }
        else{
            
            cout << "\033[1;31m Ha ocurrido un error. Por favor revisar ayuda con -h --help -?\n\n \033[0m\n" << endl;
            return ERROR;
        }
        
    }
    else 
    if (argc == 3)
    { 
        if (!regex_match(argv[1], regex("([0-9]+)")) ){  /*chequeo que no se pase algo distinto a entero por param*/
            cout << "\033[1;31m ERROR_EN_PRIMER_PARAMETRO \033[0m\n" << endl;
            cout << "\033[1;31m El primer parametro esperado es un valor entero positivo sin decimales ni letras" << endl;
            cout << "\033[1;31m Por favor revisar ayuda con -h -help o -? \n\n" << endl;
            return ERROR;
        }

        if (!regex_match(argv[2], regex("([0-9]+)")) ){  /*chequeo que no se pase algo distinto a entero por param*/
            cout << "\033[1;31m ERROR_EN_SEGUNDO_PARAMETRO \033[0m\n" << endl;
            cout << "\033[1;31m El segundo parametro esperado es un valor entero positivo sin decimales ni letras" << endl;
            cout << "\033[1;31m Por favor revisar ayuda con -h -help o -? \n\n" << endl;
            return ERROR;
        }
        
        if((atoi(argv[1]) <= 0) || (atoi(argv[2]) <= 0) || (atoi(argv[2]) > MAXVAL) ){
            cout << "\033[1;31m ERROR_EN_PARAMETROS \033[0m\n" << endl;
            cout << "\033[1;31m Se esperan valores enteros positivos \n" << endl;
            cout << "\033[1;31m Por favor revisar ayuda con -h -help o -? \n\n" << endl;
            return ERROR;
        }

    } else 
    {    
        if(argc == 0 || argv[1] == NULL){  /* solucion segmentation fault por param */
            cout << "\033[1;31m ERROR_CANTIDAD_PARAMETROS \033[0m\n" << endl;
            cout << "\033[1;31m Por favor revisar ayuda con -h -help o -? \n\n" << endl;
            return ERROR;
        }
        else{
            
            cout << "\033[1;31m Ha ocurrido un error. Por favor revisar ayuda con -h --help -?\n\n \033[0m\n" << endl;
            return ERROR;
        }
  
    }
    
 
    /*******************************************FIN VALIDACIONES***************************************/    
    
    
    
    unsigned t2, t3; // controlan el tiempo general
    t2=clock();
    int N = atoi(argv[1]); // cant de iteraciones
    int P = atoi(argv[2]);
    int acum = 0;
    thread myThreads[P];
    
    double timeGral;
    int cantCiclos = 0;

    //for(int j = M; j <= 9;)
    
    while(M <= 9)
    {
        
        cantCiclos++;
        acum = M;
        //Itero por cantidad de threads
        for (int i = 0; i < P && M <= 9; i++)
        {
            myThreads[i] = thread(Hilo, i+1, &acum, N);
            myThreads[i].join(); // es como el wait para los fork
            M++;
        }
        
    }
    
    t3=clock();
    timeGral = (double(t3-t2)/CLOCKS_PER_SEC);
    cout << "Execution Time Gral: " << timeGral << endl;
    return 0;
}