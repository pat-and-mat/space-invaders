%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"
%include "utils.inc"

section .text

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

global arrayd.shiftl
arrayd.shiftl:
    FUNC.START
    inc dword [PARAM(2)]

    .shiftl.while:
        mov ecx, [PARAM(2)]
        
        cmp ecx, [PARAM(1)]
        je .shiftl.while.end

        shl ecx, 2

        mov edx, [PARAM(0)]
        add edx, ecx

        mov eax, [edx]
        mov [edx - 4], eax

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
        jbe .shiftr.while.end

        shl ecx, 2

        mov edx, [PARAM(0)]
        add edx, ecx

        mov ax, [edx - 4]
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

;  return 1 if true, 0 if false
;  in the directions param are the amount to mov in every direction
;  in the count param is the number of graphics to check
;  engine.can_move(dword *map, dword row.offset, col.offset, dword rows, dword cols, dword count, dword down, dword up, dword right, dword left, dword hash)
global can_move
can_move:
    FUNC.START
    RESERVE(3)    

    mov dword [LOCAL(0)], 0
    while:
    mov ecx, [LOCAL(0)]
    cmp ecx, [PARAM(5)]
    je true

    shl ecx, 2

    mov eax, [PARAM(1)]
    mov dword [LOCAL(1)], eax
    mov eax, [PARAM(3)]
    add eax, ecx
    mov ebx, [eax]
    add dword [LOCAL(1)], ebx
    mov eax, [PARAM(6)]
    add dword [LOCAL(1)], eax
    mov eax, [PARAM(7)]
    sub dword [LOCAL(1)], eax

    mov eax, [PARAM(2)]
    mov dword [LOCAL(2)], eax
    mov eax, [PARAM(4)]
    add eax, ecx
    mov ebx, [eax]
    add dword [LOCAL(2)], ebx
    mov eax, [PARAM(8)]
    add dword [LOCAL(2)], eax
    mov eax, [PARAM(9)]
    sub dword [LOCAL(2)], eax
    
    OFFSET [LOCAL(1)], [LOCAL(2)]

    shl eax, 2
    add eax, dword [PARAM(0)]

    mov edx, [PARAM(10)]

    cmp dword [eax], edx
    jne can_be_false
    no_false:
    mov dword [eax], edx
    add dword [LOCAL(0)], 1
    jmp while

    can_be_false:
    cmp dword [eax], 0
    jne false
    jmp no_false
    
    true:
    mov eax, 1
    jmp return

    false:
    mov eax, 0

    return:
    FUNC.END