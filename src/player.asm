%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"

extern print
extern clear
extern erase
extern scan

%define SHIP.COORDS 6

%macro SHIP.ROW 1
    xor eax, eax
    mov ax, [row.offset]
    add ax, %1
%endmacro

%macro SHIP.COL 1
    xor eax, eax
    mov ax, [col.offset]
    add ax, %1
%endmacro

; Data section is meant to hold constant values, do not modify
section .data

graphics dw 'A'|FG.YELLOW|BG.BLACK,\
            '('|FG.YELLOW|BG.BLACK,\
            ')'|FG.YELLOW|BG.BLACK,\
            '^'|FG.YELLOW|BG.BLACK,\
            'W'|FG.YELLOW|BG.BLACK,\
            'W'|FG.YELLOW|BG.BLACK,

rows dw 0, 1, 1, 3, 3, 3
cols dw 2, 1, 3, 2, 1, 3

row.top dw 0
row.bottom dw 0

col.left dw 0
col.right dw 4

section .bss

map resd 1
canvas resd 1

lives resw 1

row.offset resw 1
col.offset resw 1

hash resw 1

section .text

; init(word lives, word r.offset, word c.offset, word hash, dword map, dword canvas)
; Initialize player
global player.init
player.init:
    FUNC.START
    ;filling local vars of player
    mov bx, [PARAM.DW(0)]
    mov [lives], bx
    
    mov bx, [PARAM.DW(1)]
    mov [row.offset], bx
    
    mov bx, [PARAM.DW(2)]
    mov [col.offset], bx
    
    mov bx, [PARAM.DW(3)]
    mov [hash], bx
    
    mov bx, [PARAM.DW(4)]
    mov [map], bx
    
    mov bx, [PARAM.DW(5)]
    mov [canvas], bx
    
    FUNC.END

; update(dword *map)
; It is here where all the actions related to this object will be taking place
global player.update
player.update:
    FUNC.START
    FUNC.END

; collision(dword hash, dword row, dword col)
; It is here where collisions will be handled
global player.collision
player.collision:
    FUNC.START
    FUNC.END

; paint(dword *canvas)
; Puts the object's graphics in the canvas
global player.paint
player.paint:
    FUNC.START
    FUNC.END

; player.take_damage(dword damage)
; Takes lives away from player
; returns 0 if player remains alive after damage, 1 otherwise
global player.take_damage
player.take_damage:
    FUNC.START
    FUNC.END
