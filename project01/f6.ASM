format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        x dq ?
        strDFormat db '%lf', 0
        strIFormat db '%d', 0
        inputStr db 'Enter the x:', 10, 0
        wrongInputStr db 'X must be [-1;1]!', 10, 0
        arccosStr db 'Arccos(x) = %lf', 10, 0
        empty db '', 10, 0
        rubb dq ?
        one dq 1.0
        four dq 4.0
        answer dq ?
        f1_1 dq -1.0
        f1_2 dq 0.0
        f2 dq 1.0
        dit dq 1.0




;--------------------------------------------------------------------------
section '.code' code readable executable

start:
        finit     ;инициализация сопроцессора.
        jmp Input
Input:
        push inputStr  ;Вывод строки ввода
        call [printf]
        add esp, 4

        push x
        push strDFormat
        call [scanf]  ;Ввод числа x
        add esp, 4

        fld1
        fld [x]
        fabs
        fcom st1      ;Сравнение введённого числа с 1 (по модулю)
        fstsw ax
        sahf
        fstp [rubb]
        fstp [rubb]
        ja WrongInput

        jmp Arccos
WrongInput:
        push wrongInputStr ;Вывод сообщения о неправильном вводе
        call [printf]
        add esp, 4

        jmp Input

Arccos:
        lea esi, [x]

        fld qword [esi]
        fld [one]
        fld [one]
        fld [one]
        fld qword [esi]


        mov ebx, 1

        ;В st0 будет хранится x^(2i+1)
        ;В st1 будет храниться (2i)!
        ;В st2 будет храниться (i!)^2
        ;В st3 будет храниться 4^i
        ;В st4 будет храниться сумма.

        cycle:
                ;----- В этом блоке считается x^(2i+1)
                fld qword [esi]

                fmul st1, st0
                fmul st1, st0

                fstp [rubb]
                ;-------------В этом блоке считается 4^i
                fld [four]          ;Добавляем в стэк 4.0

                fmul st4, st0

                fstp [rubb]
                ;-------------В этом блоке считается (i!)^2
                fld [f2]
                fmul st0, st0
                fmul st3, st0

                fsqrt
                fld [one]
                fadd st1, st0

                fstp [rubb]
                fstp [f2]
                ;-------------В этом блоке считается (2i)!
                fld [f1_1]
                fld [f1_2]
                fld [one]

                fadd st1, st0
                fadd st1, st0
                fadd st2, st0
                fadd st2, st0

                fstp [rubb]

                fmul st3, st0
                fxch st1
                fmul st3, st0
                fxch st1

                fstp [f1_2]
                fstp [f1_1]
                ;-------------В этом блоке мы по формуле собираем посчитанные числа, делим их на (2i+1) и получаем один член нашей суммы.
                fldz
                fadd st0, st1

                fmul st0, st2
                fdiv st0, st4
                fdiv st0, st3


                fld [dit]
                fld [one]
                fadd st1, st0
                fstp [rubb]
                fst qword[dit]
                fld [one]
                fadd st0, st0
                fmul st1, st0
                fstp [rubb]

                fld [one]
                fadd st1, st0
                fstp [rubb]

                fdiv st1, st0
                fstp [rubb]

                fadd st5, st0
                fstp [rubb]

                ;-------------Увеличение счётчика цикла.

                add ebx, 1
                cmp ebx, 870
                jne cycle

        fxch st4  ;Помещаем в вершину стека нужный ответ
        fstp [answer] ;Извлекаем его и ложим в answer.

        ;-----------Считаем Pi/2
        fldpi
        fld1
        fadd st0, st0
        fdiv st1, st0
        fstp [rubb]
        ;---------

        ;----------Вычитаем из Pi/2 answer.
        fld [answer]
        fsub st1, st0
        fstp [rubb]
        fstp [answer]


        invoke printf, arccosStr, dword[answer], dword[answer+4] ;Вывод ответа

        jmp Exit
Exit:
        call [getch]

        push 0
        call [ExitProcess]


section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'