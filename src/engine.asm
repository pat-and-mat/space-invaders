%include "video.inc"
%include "stack.inc"

%macro CLEAR 2
    mov ax, %2
    mov ecx, COLS * ROWS
    mov edi, %1
    cld
    rep stosw
%endmacro

section .bss

map resw COLS * ROWS
canvas resw COLS * ROWS

section .text

; update()
; It is here where all the actions related to this object will be taking place
global weapons.update
engine.update:
    FUNC.START
    FUNC.END

; paint()
; Puts the object's graphics in the canvas
global weapons.paint
engine.paint:
    FUNC.START
    FUNC.END

; collision()
; It is here where collisions will be handled
global engine.collision
engine.collision:
    FUNC.START
    FUNC.END