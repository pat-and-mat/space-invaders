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

; update(dword *map)
; It is here where all the actions related to this object will be taking place
global weapons.update
weapons.update:
    FUNC.START
    FUNC.END

; paint(dword *canvas)
; Puts the object's graphics in the canvas
global weapons.paint
weapons.paint:
    FUNC.START
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
    cmp ax, [shots.count]
    jne .end
    mov word [shots.rows + ecx], [PARAM(0)]
    mov word [shots.cols + ecx], [PARAM(1)]
    mov word [shots.dirs + ecx], [PARAM(2)]
    inc word [shots.count]
    .end:
        FUNC.END

; find_shot(dword row, dword col)
; returns index of a shot at row, col
weapons.find_shot:
    FUNC.START
    mov ecx, 0
    .while:
        cmp cx, [shots.count]
        jnl .end_while
        cmp word [shots.rows + ecx], [PARAM(0)]
        jne .continue
        cmp word [shots.cols + ecx], [PARAM(1)]
        jne .continue
        jmp .end_while
        .continue:
            inc ecx
            jmp .while
        .end_while:
    mov eax, ecx
    FUNC.END
