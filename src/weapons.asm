%include "video.inc"
%include "stack.inc"

%define SHOTS.COORDS 1

section .data

graphics dw 'o'|FG.RED|BG.BLACK

rows dw 0
cols dw 0

row.top dw 0
row.bottom dw 0

col.left dw 0
col.right dw 0

shots.count dw 0

section .bss

shots.rows resw ROWS * COLS
shots.cols resw ROWS * COLS
shots.dirs resw ROWS * COLS

section .text

extern video.print

; update(dword *map)
; It is here where all the actions related to this object will be taking place
global weapons.update
weapons.update:
    FUNC.START
    FUNC.END

; paint()
; Puts the object's graphics in the screen
global weapons.paint
weapons.paint:
    FUNC.START
    RESERVE(2)
    push ebx
    xor ebx, ebx
    mov bx, [shots.count]
    shl ebx, 1

    mov ecx, 0  ; ecx = 0
    .paint.while:
        cmp ecx, ebx    ; if cx >= shots.count:
        je .paint.while.end    ;   break

        xor eax, eax
        mov ax, [shots.rows + ecx]
        mov dword [LOCAL(0)], eax   ; local0 = shots.rows[ecx]
        
        xor eax, eax
        mov ax, [shots.cols + ecx]
        mov dword [LOCAL(1)], eax   ; local1 = shots.cols[ecx]

        mov byte [graphics], cl
        add byte [graphics], 48

        push ecx

        mov eax, [LOCAL(0)]
        mov edi, [LOCAL(1)]
        or eax, FG.RED
        or edi, FG.RED

        cmp eax,edi
        je .paint.while.end

        CALL video.print, eax, ecx, 0
        CALL video.print, edi, ecx, 2

        CALL weapons.paint_shot, [LOCAL(0)], [LOCAL(1)] ; paint_shot(local0, local1)
        pop ecx
        
        add ecx, 2 ; ecx+=2
        jmp .paint.while
    .paint.while.end:
    pop ebx
    FUNC.END

; weapons.paint_shot(dword row, dword col)
; Paints one shot at row, col
weapons.paint_shot:
    FUNC.START
    mov ecx, 0
    .ps.while:
        cmp ecx, SHOTS.COORDS * 2
        je .ps.while.end

        mov eax, [PARAM(0)]
        add eax, [rows + ecx]
        mov [PARAM(0)], eax

        mov eax, [PARAM(1)]
        add eax, [cols + ecx]
        mov [PARAM(1)], eax

        xor eax, eax
        mov ax, [graphics + ecx]

        push ecx
        CALL video.print, eax, [PARAM(0)], [PARAM(1)]
        pop ecx
        
        add ecx, 2
        jmp .ps.while
    .ps.while.end:
    FUNC.END

; collision(dword other_hash, dword row, dword col)
; It is here where collisions will be handled
global weapons.collision
weapons.collision:
    FUNC.START
    FUNC.END

; weapons.shoot(dword row, dword col, dword dir)
; creates a shot in position row, column that will move in direction dir
; (dir = 0) => shot moves down 
; (dir = 1) => shot moves up
global weapons.shoot
weapons.shoot:
    FUNC.START
    CALL weapons.find_shot, [PARAM(0)], [PARAM(1)]
    push ebx
    xor ebx, ebx
    mov bx, [shots.count]
    shl ebx, 1

    cmp eax, ebx
    jne .end
    mov edx, [PARAM(0)]
    mov word [shots.rows + eax], dx
    mov edx, [PARAM(1)]
    mov word [shots.cols + eax], dx
    mov edx, [PARAM(2)]
    mov word [shots.dirs + eax], dx
    inc word [shots.count]
    
    .end:
        pop ebx
        FUNC.END

; find_shot(dword row, dword col)
; returns index of a shot at row, col
weapons.find_shot:
    FUNC.START
    push ebx

    xor ebx, ebx
    mov bx, [shots.count]
    shl ebx, 1

    mov ecx, 0
    .while:
        cmp ecx, ebx
        je .end_while
        mov eax, [PARAM(0)]
        cmp [shots.rows + ecx], ax
        jne .continue
        mov eax, [PARAM(1)]
        cmp [shots.cols + ecx], ax
        jne .continue
        jmp .end_while
        .continue:
            add ecx, 2
            jmp .while
        .end_while:
    mov eax, ecx

    pop ebx
    FUNC.END
