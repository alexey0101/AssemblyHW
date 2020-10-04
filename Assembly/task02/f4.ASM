;Вариант 11, Массив B из элементов A в обратном порядке, за исключением первого положительного
format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'size of vector? ', 0
        strIncorSize db 'Incorrect size of vector = %d', 10, 0
        strVecElemI  db '[%d]? ', 0
        strScanInt   db '%d', 0
        strVecElemOut  db '[%d] = %d', 10, 0
        strAVector db 'Vector A: ', 10, 0
        strBVector db 'Vector B: ', 10, 0

        flag         dd 0
        vec_size     dd 0
        i            dd ?
        j            dd ?
        tmpA         dd ?
        tmpB         dd ?
        tmpStack     dd ?
        vecA         rd 100
        vecB         rd 100

;--------------------------------------------------------------------------
section '.code' code readable executable
start:

        call VectorInput

        call VectorCopy

        push strAVector
        call [printf]
        add esp, 4

        call VectorAOut

        push strBVector
        call [printf]
        add esp, 4

        call VectorBOut
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:

        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 0
        jg  getVector

        push vec_size
        push strIncorSize
        call [printf]
        push 0
        call [ExitProcess]

getVector:
        xor ecx, ecx
        mov ebx, vecA
getVecLoop:
        mov [tmpA], ebx
        cmp ecx, [vec_size]
        jge endInputVector

        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmpA]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret
;--------------------------------------------------------------------------
VectorCopy:
        add ebx, -4
getVectors:
        xor ecx, ecx
        mov edx, vecB
getVectorsLoop:
        mov [tmpA], ebx
        mov [tmpB], edx
        cmp ecx, [vec_size]
        jge endCopying

        mov [i], ecx
        mov eax, [ebx]

        cmp [flag], 0
        jg CopyElement

        jmp CheckIfElementIsPositive

CopyElement:
        mov [edx], eax
        mov ecx, [i]
        inc ecx
        mov ebx, [tmpA]
        mov edx, [tmpB]
        add ebx, -4
        add edx, 4
        jmp getVectorsLoop

CheckIfElementIsPositive:
        cmp eax, 0
        jg IgnoreElement

        jmp CopyElement

IgnoreElement:
        mov [flag], 1
        mov ecx, [i]
        inc ecx
        mov ebx, [tmpA]
        mov edx, [tmpB]
        add ebx, -4
        jmp getVectorsLoop
endCopying:
        ret
;--------------------------------------------------------------------------
VectorAOut:
        mov [tmpStack], esp
        xor ecx, ecx
        mov ebx, vecA

putVecALoop:
        mov [tmpA], ebx
        cmp ecx, [vec_size]
        je endOutputAVector
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmpA]
        add ebx, 4
        jmp putVecALoop
endOutputAVector:
        mov esp, [tmpStack]
        ret
;--------------------------------------------------------------------------
VectorBOut:
        mov [tmpStack], esp
        xor ecx, ecx
        mov edx, vecB
        xor ebx, ebx


        cmp [flag], 0
        jg DecVecSize

        jmp putVecBLoop
DecVecSize:
        mov eax, [vec_size]
        dec eax
        mov [vec_size], eax
putVecBLoop:
        mov [tmpB], edx
        cmp ecx, [vec_size]
        jge endOutputBVector
        mov [i], ecx

        ; output element
        push dword [edx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov edx, [tmpB]
        add edx, 4
        jmp putVecBLoop
endOutputBVector:
        mov esp, [tmpStack]
        ret
                                                 
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