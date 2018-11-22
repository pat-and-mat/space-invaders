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

timer resd 1

section .text

extern video.print
extern delay

; update(dword *map)
; It is here where all the actions related to this object will be taking place
global weapons.update
weapons.update:
    FUNC.START
    RESERVE(1)  ; i

    CALL delay, timer, 50
    cmp eax, 0
    je .update.move.end

    mov dword [LOCAL(0)], 0
    .update.move:
        mov ecx, [LOCAL(0)]
        
        cmp cx, [shots.count]
        je .update.move.end

        shl ecx, 1

        xor eax, eax
        mov ax, [shots.dirs + ecx]
        
        cmp eax, 0
        je .move.down

        cmp eax, 1
        je .move.up

        jmp .update.move.end

        .move.up:
            dec word [shots.rows + ecx]
            jmp .update.move.cont

        .move.down:
            inc word [shots.rows + ecx]
            jmp .update.move.cont

        .update.move.cont:
            inc dword [LOCAL(0)]
            jmp .update.move
    .update.move.end:

    FUNC.END

; paint()
; Puts the object's graphics in the screen
global weapons.paint
weapons.paint:
    FUNC.START
    RESERVE(3)  ; i, row, col

    mov dword [LOCAL(0)], 0
    .paint.while:
        mov ecx, [LOCAL(0)]
        
        cmp cx, [shots.count]
        je .paint.while.end

        shl ecx, 1

        xor eax, eax
        mov ax, [shots.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [shots.cols + ecx]
        mov [LOCAL(2)], eax

        CALL weapons.paint_shot, [LOCAL(1)], [LOCAL(2)]
        
        inc dword [LOCAL(0)]
        jmp .paint.while
    .paint.while.end:

    FUNC.END

; weapons.paint_shot(dword row, dword col)
; Paints one shot at row, col
weapons.paint_shot:
    FUNC.START
    RESERVE(2)  ; coord, graphics

    mov dword [LOCAL(0)], 0
    .pshot.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, SHOTS.COORDS
        je .pshot.while.end

        shl ecx, 1
        
        xor eax, eax
        mov ax, [rows + ecx]
        add [PARAM(0)], eax
        
        xor eax, eax
        mov ax, [cols + ecx]
        add [PARAM(1)], eax

        xor eax, eax
        mov ax, [graphics + ecx]
        mov [LOCAL(1)], eax

        CALL video.print, [LOCAL(1)], [PARAM(0)], [PARAM(1)]

        inc dword [LOCAL(0)]
        jmp .pshot.while
    .pshot.while.end:

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

    mov ecx, eax

    cmp cx, [shots.count]
    jne .shoot.end

    shl ecx, 1

    mov eax, [PARAM(0)]
    mov [shots.rows + ecx], ax
    
    mov eax, [PARAM(1)]
    mov [shots.cols + ecx], ax

    mov eax, [PARAM(2)]
    mov [shots.dirs + ecx], ax

    inc word [shots.count]

    .shoot.end:
        FUNC.END

; find_shot(dword row, dword col)
; returns index of a shot at row, col
weapons.find_shot:
    FUNC.START
    RESERVE(1)  ; i

    mov dword [LOCAL(0)], 0
    .find.while:
        mov ecx, [LOCAL(0)]
        
        cmp cx, [shots.count]
        je .find.while.end

        shl ecx, 1

        mov eax, [PARAM(0)]
        cmp [shots.rows + ecx], eax
        jne .find.while.cont

        mov eax, [PARAM(1)]
        cmp [shots.cols + ecx], eax
        jne .find.while.cont

        jmp .find.while.end
        
        .find.while.cont:
            inc dword [LOCAL(0)]
            jmp .find.while
    .find.while.end:

    mov eax, [LOCAL(0)]

    FUNC.END
