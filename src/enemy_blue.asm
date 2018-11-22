%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"
%include "hash.inc"

extern video.print_at
extern video.print
extern video.clear
extern scan
extern delay

;each ship will have 4 parts, that's why it's reserved space for 500 ships(COLS * ROWS / 4)
%define ZIZE 500
%define SHIP.COORDS 4

section .data

timer dd 0

count dd 0

graphics dd '\'|FG.BLUE|BG.BLACK,\
            '/'|FG.BLUE|BG.BLACK,\
            'O'|FG.BLUE|BG.BLACK,\
            'V'|FG.BLUE|BG.BLACK,
            
            
rows dd 0, 0, 0, 1
cols dd 0, 2, 1, 1

row.top dd 0
row.bottom dd 3

col.left dd 0
col.right dd 3

hash dd 3

;ship's IA

section .bss

row.offset resd ZIZE
col.offset resd ZIZE

lives resd ZIZE

;1-Rigth 0-left
dir resd ZIZE

section .text

;init(dw row.offset, dw col.offset)
; Initialize a blue enemy
global enemy_blue.init
enemy_blue.init:
    FUNC.START

    ;filling local vars
    mov eax, dword [count]     

    mov edx, [PARAM(0)]
    mov [row.offset + eax], edx 

    mov edx, [PARAM(1)]
    mov [col.offset + eax], edx

    mov dword [lives + eax], 1

    ;pointer of the actual moviment
    mov dword [dir + eax], 1

    add dword [count], 4   

    FUNC.END

;update()
;move all the blue enemies
global enemy_blue.update
enemy_blue.update:
    FUNC.START

    cmp dword [count], 0
    je working.on.map
   
    mov ecx, 0

    start:
        cmp dword [dir + ecx], 0
        je left
        jg right

        left:
        cmp dword [col.offset + ecx], 0
        je move.down
        jmp move.left

        right:
        cmp dword [col.offset + ecx], 77
        je move.down
        jmp move.right

        condition:  ;the stop condition is reached when all the ships are moved
        add ecx, 4
        cmp ecx, dword [count]  ;compare ecx with the number of blue ships on map * 4
        jl start
        jmp working.on.map  ;end cicle

        move.right:        
        add dword [col.offset + ecx] , 1
        jmp condition

        move.left:
        sub dword [col.offset + ecx] , 1
        jmp condition

        move.up:
        sub dword [row.offset + ecx] , 1
        jmp condition

        move.down:
        ;check position

        cmp dword [dir + ecx], 0
        jne set.left
        set.right:
        mov dword [dir + ecx], 1
        add dword [row.offset + ecx] , 3
        jmp condition
        set.left:
        mov dword [dir + ecx], 0
        add dword [row.offset + ecx] , 3
        jmp condition
        
    working.on.map:

        end:

    FUNC.END

;paint()
;move all the blue enemies
global enemy_blue.paint
enemy_blue.paint:
    FUNC.START
    RESERVE(2)
    
    cmp dword [count], 0
    je while.end
   
    mov esi, 0    
    mov ecx, 0 
    
    ;painting ship number esi * 4
    while.internal:       
        cmp ecx, SHIP.COORDS * 4
        jnl while.external
        
        mov eax, [row.offset + esi]
        add eax, [rows + ecx]
        mov [LOCAL(0)], eax

        mov eax, [col.offset + esi]
        add eax, [cols + ecx]
        mov [LOCAL(1)], eax

        ;CALL video.print_at, [PARAM(0)], [graphics + ecx], ebx, edx
        CALL video.print, [graphics + ecx], [LOCAL(0)], [LOCAL(1)]
        add ecx, 4
        jmp while.internal

    ;updating esi
    while.external:
        mov ecx, 0  
        add esi, 4
        cmp esi, dword [count]
        jl while.internal
        while.end:

    FUNC.END

; enemy_blue.take_damage(dword damage)
; Takes lives away from player
; returns 0 if player remains alive after damage, 1 otherwise
global enemy_blue.take_damage
enemy_blue.take_damage:
    FUNC.START
    FUNC.END

