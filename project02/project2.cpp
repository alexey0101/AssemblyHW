#include <pthread.h>
#include <semaphore.h>
#include <stdlib.h>
#include <stdio.h>
#include <chrono>
#include <iostream>
#include <thread>
#include <queue>

pthread_mutex_t mutex[3]; //отдельные мьютексы для каждого отдела

pthread_cond_t empty[3]; //потоки-продавцы блокируются этой переменной, когда в очереди к продавцу никого нет (отдельная переменная для каждого отдела).
pthread_cond_t not_empty[3]; //потоки-покупатели блокируются этой переменной, когда к интересующему продавцу выстроилась очередь (отдельная переменная для каждого отдела).

std::queue<int> firstDep; //очередь для первого отдела.
std::queue<int> secondDep; //очередь для второго отдела.
std::queue<int> thirdDep; //очередь для третьего отдела.

int values[3] = { 0, 0, 0 }; //массив для хранения последних значений сумм товаров.

//стартовая функция потоков – продавцов
void* Salesman(void* param) {
    srand(time(NULL)); //инициализатор генератора случайных чисел, зависящий от текущего времени.
    int pNum = *((int*)param); //номер продавца
    int price; //цена, за которую покупатель купил товар
    while (1) {
        pthread_mutex_lock(&mutex[pNum - 1]); //защита операции чтения

        //заснуть, если в очереди нет покупателей.
        while (pNum == 1 && firstDep.size() == 0 || pNum == 2 && secondDep.size() == 0 || pNum == 3 && thirdDep.size() == 0) {
            pthread_cond_wait(&empty[pNum - 1], &mutex[pNum - 1]);
        }

        price = values[pNum - 1]; //получение значения цены товара.

        printf("Department %d got %d from customer\n", pNum, price);

        //удаление покупателя из очереди после покупки.
        switch (pNum)
        {
        case 1:
            firstDep.pop();
            break;
        case 2:
            secondDep.pop();
            break;
        case 3:
            thirdDep.pop();
            break;
        default:
            break;
        }

        //конец критической секции
        pthread_mutex_unlock(&mutex[pNum - 1]);
        //разбудить потоки-покупатели после продажи товара клиенту.
        pthread_cond_broadcast(&not_empty[pNum - 1]);

        std::this_thread::sleep_for(std::chrono::milliseconds(1000)); //заснуть текущему потоку на секунду.
    }
    return NULL;
}

//стартовая функция потоков – покупателей.
void* Customer(void* param) {
    srand(time(NULL)); //инициализатор генератора случайных чисел, зависящий от текущего времени.
    int cNum = *((int*)param); //номер покупателя.

    int price; //цена товара
    int depNum; //номер отдела, в который хочет пойти покупатель.
    while (1) {
        depNum = rand() % 3;

        price = rand() % 1000;

        pthread_mutex_lock(&mutex[depNum]); //защита операции записи.

        printf("Consumer %d decided to go to %d department\n", cNum, depNum + 1);

        //добавление покупателя в очередь.
        switch (depNum)
        {
        case 0:
            firstDep.push(cNum);
            break;
        case 1:
            secondDep.push(cNum);
            break;
        case 2:
            thirdDep.push(cNum);
            break;
        default:
            break;
        }

        //Покупатель спит, пока не окажется первым в очереди.
        while (depNum == 0 && firstDep.front() != cNum || depNum == 1 && secondDep.front() != cNum || depNum == 2 && thirdDep.front() != cNum) {
            pthread_cond_wait(&not_empty[depNum], &mutex[depNum]);
        }

        values[depNum] = price; //запись цены товара.

        printf("Consumer %d bought something with price %d in %d department\n", cNum, price, depNum + 1);

        //конец критической секции.
        pthread_mutex_unlock(&mutex[depNum]);
        //разбудить потоки-продавцы.
        pthread_cond_broadcast(&empty[depNum]);

        std::this_thread::sleep_for(std::chrono::milliseconds(1000)); //заснуть текущему потоку на секунду.
    }
    return NULL;
}

int main() {
    int i;

    //инициализация мьютексов и усл. переменных.
    for (i = 0; i < 3; i++) {
        pthread_mutex_init(&mutex[i], NULL);
        pthread_cond_init(&empty[i], NULL);
        pthread_cond_init(&not_empty[i], NULL);
    }


    pthread_t threadS[3];
    int salesmans[3];
    for (i = 0; i < 3; i++) {
        salesmans[i] = i + 1;
        pthread_create(&threadS[i], NULL, Salesman, (void*)(salesmans + i));
    }

    //запуск потребителей
    pthread_t threadC[4];
    int customers[4];
    for (i = 0; i < 4; i++) {
        customers[i] = i + 1;
        pthread_create(&threadC[i], NULL, Customer, (void*)(customers + i));
    }

    //Мэйн становится потоком-покупателем.
    int mNum = 0;
    Customer((void*)&mNum);
    return 0;
}