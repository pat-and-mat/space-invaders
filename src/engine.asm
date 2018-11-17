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

extern player.update
extern weapons.update

extern player.paint
extern weapons.paint
extern video.set_buffer

; update()
; It is here where all the actions related to this object will be taking place
engine.update:
    FUNC.START
    CLEAR map, 0
    CALL player.update, map
    CALL weapons.update, map
    FUNC.END

; paint()
; Puts the object's graphics in the canvas
engine.paint:
    FUNC.START
    CLEAR canvas, BG.BLACK
    CALL player.paint, canvas
    CALL weapons.paint, canvas
    CALL video.set_buffer, canvas
    FUNC.END

; collision()
; It is here where collisions will be handled
engine.collision:
    FUNC.START
    FUNC.END

; engine.run()
; Runs a whole iteration of the engine
global engine.run
engine.run:
    FUNC.START
    call engine.update
    call engine.paint
    FUNC.END