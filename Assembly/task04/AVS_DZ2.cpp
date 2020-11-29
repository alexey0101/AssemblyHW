#include <iostream>
#include <iomanip>
#include <limits>
#include <omp.h>

int* arr;
int size = 0;

struct Package {
    int startIndex = 0;
    int maxValueIndex = 1;
    int maxValue = 0;
};

/// <summary>
/// Считает максимальное значение arr[p.startIndex] - arr[p.startIndex + 1] + ... +- arr[startIndex + j], индекс j.
/// </summary>
/// <param name="p"></param>
void func(Package& p) {

    p.maxValueIndex = p.startIndex + 1;
    p.maxValue = arr[p.startIndex] - arr[p.startIndex + 1];

    int sign = 1;

    int currentValue = p.maxValue;

    for (int i = p.startIndex + 2; i < size; i++)
    {
        currentValue += sign * arr[i];

        if (currentValue > p.maxValue)
        {
            p.maxValue = currentValue;
            p.maxValueIndex = i;
        }

        sign *= -1;
    }

}


/// <summary>
/// Добавляет элемент в массив.
/// </summary>
/// <param name="arr"></param>
/// <param name="size"></param>
/// <param name="value"></param>
void push_element(int*& arr, int& size, int value)
{
    int* newArray = new int[size + 1];

    for (int i = 0; i < size; i++)
    {
        newArray[i] = arr[i];
    }

    newArray[size] = value;

    delete[] arr;

    arr = newArray;

    size++;
}


int main(int argc, char* argv[]) {

    if (argc == 1) { //Ввод массива.

        std::cout << "Enter array A:" << std::endl;

        int value;

        while (std::cin >> value) //Ввод массива
        {
            push_element(arr, size, value);
        }

        if (size <= 10) //Проверка на размер массива.
        {
            std::cout << std::endl << "Incorrect size of array, it must be at least 11 elements" << std::endl;

            return 0;
        }
    }
    else { //Ввод массива, в случае, если он был передан через командную строку.
        arr = new int[argc - 1];
        size = argc - 1;

        if (size <= 10)
        {
            std::cout << std::endl << "Incorrect size of array, it must be at least 11 elements" << std::endl;

            return 0;
        }

        for (int i = 0; i < argc - 1; i++) {

            arr[i] = atoi(argv[i + 1]);
        }
    }

    Package* pack = new Package[size - 1];

    int firstIndex = 0;
    int secondIndex = pack[0].maxValueIndex;
    int maxValue = pack[0].maxValue;

    #pragma omp parallel for
    for (int i = 0; i < size - 1; i++) { //Запуск потока от каждого индекса, кроме последнего.
        pack[i].startIndex = i;
        func(pack[i]);
        
        #pragma omp critical
        {
            if (pack[i].maxValue > maxValue) //Сравниваем результат с максимумом.
            {
                firstIndex = pack[i].startIndex;
                secondIndex = pack[i].maxValueIndex;
                maxValue = pack[i].maxValue;
            }
        }

    }

    std::cout << std::endl << "Max value is reached with indexes " << firstIndex << " and " << secondIndex << " " << "(" << maxValue << ")" << std::endl;

    delete[] arr;
    delete[] pack;
    return 0;
}