#include <iostream>
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <list>
#include <cstring>
#include <fcntl.h>
#include <semaphore.h>
#include <stdio.h>
#include <stdio_ext.h>

using namespace std;


void imprimirNivel(int nivelIni,int nivel, int nodo, int arbol[],int miPid)
{
    if(nodo != 1){
        cout << endl;
  cout << "Nivel: " << (nivelIni-nivel+1) << " - Num nodo: " << nodo << " - Pid Proceso: " << miPid <<"      ";
    cout << " Predecesores: ";
    int n=nivelIni-nivel;
    for (int i = 0; i < n; i++)
    {
        cout << " " << arbol[i];
    }
cout  << endl << endl ;

    }
  
}

void ayuda()
{
    cout << "-------------------------------------------------------" << endl;
    cout << "\t- Ayuda del Script   Ejercicio1 ..." << endl;
    cout << "\t- Nombre Script:     ./Ejercicio1    " << endl;
    cout << "\t- Ejemplo de uso:    ./Ejercicio1 3" << endl;
    cout << "\t- N     Numero entero mayor a 1" << endl;
    cout << "\t- Fin de la ayuda... espero te sirva!" << endl;
    cout << "-------------------------------------------------------" << endl;
}

void crearHijos(int nivelIni,int nivel, int nodo, int arbolgenialogico[],sem_t * mutex, sem_t *semHijo,sem_t *semHijo2)
{
    sem_wait(mutex);
   arbolgenialogico[nivelIni-nivel] = getpid();
    
    imprimirNivel(nivelIni,nivel,nodo,arbolgenialogico,getpid());
    sem_post(mutex);
    
    if (nivel <= 1)
    { 
        //cout << "Pulse enter para continuar" <<endl;
        //cin.get();
        sleep(20);
        return;   
        
    }
    int pid = fork();
    if (pid)
    { //padre
    
        int pid2 = fork();
        if (pid2)
        {
           sem_post(semHijo);
             
            wait(NULL);
            wait(NULL);
            
        }
        else
        {
            nodo = nodo * 2 + 1; 
            sem_wait(semHijo2) ;
            crearHijos(nivelIni,nivel - 1, nodo, arbolgenialogico,mutex,semHijo,semHijo2);
        }
    }
    else //hijo
    {   
        sem_wait(semHijo);
        nodo = nodo * 2;
        sem_post(semHijo2);
        crearHijos(nivelIni,nivel - 1, nodo, arbolgenialogico,mutex,semHijo,semHijo2);
    }


}


int main(int argc, char *argv[])
{
    int pidInicial=getpid();
    
    int nivel;
    int nivelIni;
    int nodo = 1;
  //Validación de parametros.
    if (argc != 2)
    {
        cout << "Cantidad de parametros invalida." << endl;
        cout << "Llamando a la ayuda..." << endl;
        ayuda();
        return EXIT_SUCCESS;
    }
    else
    {
        if (strcmp(argv[1], "-help") == 0 || strcmp(argv[1], "-h") == 0)
        {
            ayuda();
            return EXIT_SUCCESS;
        }
        else
        {
            if (atoi(argv[1]) <= 1)
            {

                cout << "Se espera un numero natural mayor a 1." << endl;
                ayuda();
                return EXIT_SUCCESS;
            }
            else
            {

                nivel = atoi(argv[1]);
                nivelIni = atoi(argv[1]);
            }
        }
    }
    //Fin de la validación de parametros.

    sem_t *mutex = sem_open("miSem", O_CREAT, 0600, 1);
    sem_t *hijo1= sem_open("hijo",O_CREAT, 0600, 0);
    sem_t *hijo2= sem_open("hijo2",O_CREAT, 0600, 0);
    int arbolgenialogico[nivel];

    arbolgenialogico[0] = getpid();
    crearHijos( nivelIni, nivel, nodo, arbolgenialogico,mutex,hijo1,hijo2);

    sem_close(mutex);
    sem_unlink("mutex");

    sem_close(hijo1);
    sem_unlink("hijo");

    sem_close(hijo2);
    sem_unlink("hijo2");

    // if(pidInicial == getpid())
    // {
    //     char c[246];
    //     cout<<"Presione cualquier tecla para continuar..." << endl;
    //     cin.getline(c,256);
    // }
    return EXIT_SUCCESS;
}