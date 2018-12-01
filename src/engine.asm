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

section .text

extern player.init

extern player.update
extern weapons.update
extern enemy.update
extern sound.update

extern info.paint
extern player.paint
extern weapons.paint
extern enemy.paint
extern video.clear
extern video.refresh

extern enemy_manager.reset
extern weapons.reset

; update()
; It is here where all the actions related to this object will be taking place
engine.update:
    FUNC.START
    CLEAR map, 0
    CALL player.update, map
    CALL weapons.update, map
    CALL enemy.update, map
    call sound.update
    FUNC.END

; paint()
; Puts the object's graphics in the screen
engine.paint:
    FUNC.START
    CALL video.clear, BG.BLACK
    call player.paint
    call weapons.paint
    call enemy.paint
    call info.paint
    call video.refresh    
    FUNC.END

; collision()
; It is here where collisions will be handled
engine.collision:
    FUNC.START
    FUNC.END

; engine.start()
; Initializes the game
global engine.start
engine.start:
    FUNC.START
    CALL player.init, 99, 20, 38
    FUNC.END

; engine.run()
; Runs a whole iteration of the engine
global engine.run
engine.run:
    FUNC.START
    call engine.update
    call engine.paint
    FUNC.END

;engine.reset()
;reset the game
global engine.reset
engine.reset:
    FUNC.START
    CALL player.init, 99, 20, 38
    call enemy_manager.reset
    call weapons.reset
    FUNC.END