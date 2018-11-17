%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"

extern video.print_at
extern video.print
extern video.clear
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

graphics dd 'H'|FG.YELLOW|BG.BLACK,\
            '('|FG.YELLOW|BG.BLACK,\
            ')'|FG.YELLOW|BG.BLACK,\
            '^'|FG.YELLOW|BG.BLACK,\
            'W'|FG.YELLOW|BG.BLACK,\
            'W'|FG.YELLOW|BG.BLACK,
            
rows dd 0, 1, 1, 2, 2, 2
cols dd 1, 0, 2, 1, 0, 2

row.top dd 0
row.bottom dd 3

col.left dd 0
col.right dd 3

section .bss

lives resw 1

row.offset resd 1
col.offset resd 1

hash resd 1

section .text

; init(word lives, dword r.offset, dword c.offset, word hash)
; Initialize player
global player.init
player.init:
    FUNC.START
    ;filling local vars of player
    mov bx, [PARAM(0)]
    mov [lives], bx
    
    mov ebx, [PARAM(1)]
    mov [row.offset], ebx
    
    mov ebx, [PARAM(2)]
    mov [col.offset], ebx
    
    mov bx, [PARAM(3)]
    mov [hash], bx
    FUNC.END

; update(dword key, dword *map)
; It is here where all the actions related to this object will be taking place
global player.update
player.update:
    FUNC.START

    .input:
       mov eax, [PARAM(0)]    
    ;   see imput and compare with keys      

    ;   call scan  
      ;up botton
      cmp eax, dword "up"
      jz up

      ;down botton
      cmp eax, dword "down"
      je down  

      ;left botton
      cmp eax, dword "left"
      je left  

      ;right botton
      cmp eax, dword "right"
      je right  

      ;enter botton
      cmp eax, dword "ent"
      je ent

      jmp update.out

      up:
      sub dword [row.offset], 1
      jmp update.out

      down:
      add dword [row.offset], 1
      jmp update.out

      left:
      sub dword [col.offset], 1
      jmp update.out

      right:
      add dword [col.offset], 1
      jmp update.out

      ent:

      update.out:

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
    RESERVE(2)

    mov ecx, 0

    xor ebx, ebx
    xor edx, edx

    while:

        cmp ecx, SHIP.COORDS * 4
        jnl while.end
        
        mov eax, [row.offset]
        add eax, [rows + ecx]
        mov ebx, eax

        mov eax, [col.offset]
        add eax, [cols + ecx]
        mov edx, eax

        CALL video.print, [graphics + ecx], ebx, edx
        add ecx, 4
        jmp while
        while.end:
        FUNC.END


    FUNC.END

; player.take_damage(dword damage)
; Takes lives away from player
; returns 0 if player remains alive after damage, 1 otherwise
global player.take_damage
player.take_damage:
    FUNC.START
    
    cmp dword [lives], 0
    jz destroyed
    sub dword [lives], 1
    FUNC.END

    destroyed:

    FUNC.END
