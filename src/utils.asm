%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"

;rand(dword range)
global rand
rand:
    FUNC.START

    rdtsc
    xor edx, edx
    div dword [PARAM(0)]
    mov eax, edx

    FUNC.END

; array.shiftl(dword *array, dword count, dword i)
; shifts elements in the array one position to the left,
; i-th elements will be removed
global array.shiftl
array.shiftl:
    FUNC.START
    inc dword [PARAM(2)]

    .shiftl.while:
        mov ecx, [PARAM(2)]
        
        cmp ecx, [PARAM(1)]
        je .shiftl.while.end

        shl ecx, 1

        mov edx, [PARAM(0)]
        add edx, ecx

        mov ax, [edx]
        mov [edx - 2], ax

        inc dword [PARAM(2)]
        jmp .shiftl.while
    .shiftl.while.end:

    FUNC.END

; array.shiftr(dword *array, dword count, dword i)
; shifts elements in the array one position to the right
global array.shiftr
array.shiftr:
    FUNC.START

    dec dword [PARAM(1)]
    inc dword [PARAM(2)]

    .shiftr.while:
        mov ecx, [PARAM(1)]
        
        cmp ecx, [PARAM(2)]
        je .shiftr.while.end

        shl ecx, 1

        mov edx, [PARAM(0)]
        add edx, ecx

        mov ax, [edx - 2]
        mov [edx], ax

        dec dword [PARAM(1)]
        jmp .shiftr.while
    .shiftr.while.end:

    FUNC.END