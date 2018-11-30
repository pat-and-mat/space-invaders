%include "video.inc"
%include "stack.inc"
%include "hash.inc"

%macro CLEAR_MAP 1
    mov eax, %1
    mov ecx, COLS * ROWS
    mov edi, map
    cld
    rep stosd
%endmacro

section .data

collisions.hashes times ROWS*COLS dd 0
collisions.count dw 0

section .bss

map resd COLS * ROWS

section .text

extern array.shiftr

extern player.init

extern player.update
extern weapons.update
extern enemy.update

extern player.collision
extern weapons.collision

extern player.paint
extern weapons.paint
extern enemy.paint
extern video.clear
extern video.refresh
extern video.print

; update()
; It is here where all the actions related to this object will be taking place
engine.update:
    FUNC.START
    CLEAR_MAP 0
    mov word [collisions.count], 0
    CALL player.update, map
    CALL weapons.update, map
    ; CALL enemy.update, map
    FUNC.END

; paint()
; Puts the object's graphics in the screen
engine.paint:
    FUNC.START
    CALL video.clear, BG.BLACK
    call player.paint
    call weapons.paint
    call enemy.paint

    xor eax, eax
    mov ax, [collisions.count]
    add eax, 48
    or eax, FG.RED
    CALL video.print, eax, 24, 79

    call video.refresh
    FUNC.END

; ******************************************************************************************
; *Collisions                                                                              *
; ******************************************************************************************

; collision()
; It is here where collisions will be handled
engine.collision:
    FUNC.START
    FUNC.END

; enine.add_collision(dword hash1, dword hash2)
; Adds a collision where hash2 is already in the map and hash1 is colliding with it
global engine.add_collision
engine.add_collision:
    FUNC.START
    FUNC.END

; *******************************************************************************************

; engine.start()
; Initializes the game
global engine.start
engine.start:
    FUNC.START
    CALL player.init, 100, 20, 38
    FUNC.END

; engine.run()
; Runs a whole iteration of the engine
global engine.run
engine.run:
    FUNC.START
    call engine.update
    call engine.collision
    call engine.paint
    FUNC.END