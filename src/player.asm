%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"

%define SHIP.COORDS 5

; Data section is meant to hold constant values, do not modify
section .data

graphics dw '/'|FG.YELLOW|BG.BLACK,\
            '-'|FG.YELLOW|BG.BLACK,\
            '^'|FG.YELLOW|BG.BLACK,\
            '-'|FG.YELLOW|BG.BLACK,\
            '\'|FG.YELLOW|BG.BLACK

rows dw 0, 0, 0, 0, 0
cols dw 0, 1, 2, 3, 4

row.top dw 0
row.bottom dw 0

col.left dw 0
col.right dw 4

section .bss

lives resw 1

row.offset resw 1
col.offset resw 1

section .text

; init(dword lives, dword r.offset, dword c.offset)
; Initialize player
global player.init
player.init:
    FUNC.START
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
