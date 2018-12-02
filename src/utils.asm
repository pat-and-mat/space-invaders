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

; array.index_of(dword *array, dword count, dword elem, dword size)
global array.index_of
array.index_of:
    FUNC.START
    RESERVE(1)  ; i

    mov dword [LOCAL(0)], 0
    .index_of.while:
        mov ecx, [LOCAL(0)]
        cmp cx, [PARAM(1)]
        je .index_of.while.end

        mov eax, ecx
        mul dword [PARAM(3)]
        mov ecx, eax

        mov eax, [PARAM(0)]
        add eax, ecx

        mov edx, [PARAM(2)]

        cmp dword [PARAM(3)], 1
        je .size_b

        cmp dword [PARAM(3)], 2
        je .size_w

        cmp dword [PARAM(3)], 4
        je .size_d

        .size_b:
            cmp [eax], dl
            jmp .index_of.while.cont

        .size_w:
            cmp [eax], dx
            jmp .index_of.while.cont

        .size_d:
            cmp [eax], edx
            jmp .index_of.while.cont

        .index_of.while.cont:
            je .index_of.while.end

        inc dword [LOCAL(0)]
        jmp .index_of.while
    .index_of.while.end:

    mov eax, [LOCAL(0)]
    FUNC.END