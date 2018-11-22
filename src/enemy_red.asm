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

graphics dd 'W'|FG.RED|BG.BLACK,\
            'W'|FG.RED|BG.BLACK,\
            '^'|FG.RED|BG.BLACK,\
            'V'|FG.RED|BG.BLACK,
            
rows dd 0, 0, 0, 1
cols dd 0, 2, 1, 1

row.top dd 0
row.bottom dd 3

col.left dd 0
col.right dd 3

hash dd 3

;ship's IA
cicle.x dd 2, 1, 0, 1
cicle.y dd 1, 2, 1, 0


section .bss

row.offset resd ZIZE
col.offset resd ZIZE

lives resd ZIZE

cicle.x_pointer resd ZIZE
cicle.y_pointer resd ZIZE

section .text

;init(dw row.offset, dw col.offset)
; Initialize a red enemy
global enemy_red.init
enemy_red.init:
    FUNC.START

    ;filling local vars
    mov eax, dword [count]     

    mov edx, [PARAM(0)]
    mov [row.offset + eax], edx 

    mov edx, [PARAM(1)]
    mov [col.offset + eax], edx

    mov dword [lives + eax], 1

    ;pointer of the actual moviment
    mov dword [cicle.x_pointer + eax], 0
    mov dword [cicle.y_pointer + eax], 0

    add dword [count], 4   

    FUNC.END

;update()
;move all the blue enemies
global enemy_red.update
enemy_red.update:
    FUNC.START

    ; xor ebx, ebx
    ; xor edx, edx
    ; CALL delay, timer, 1000
    ; cmp eax, 0
    ; je end

    cmp dword [count], 0
    je working.on.map
   
    mov ecx, 0

    update.x:
        xor ebx, ebx        
        ;updating x position of all ships
        mov ebx, dword [cicle.x_pointer + ecx]
        add dword [cicle.x_pointer + ecx], 4
        cmp dword [cicle.x_pointer + ecx], 12  ;checking if is necesary reset the movements cicle
        jg restart.cicle.x

        continue.x:   ;for come back from the reset

        cmp dword [cicle.x + ebx], 1
        jl move.left
        jg move.right
        ;if there is not movement in x, continue to update.y

    update.y:
        ;updating y position of all ships
        mov ebx, dword [cicle.y_pointer + ecx]
        add dword [cicle.y_pointer + ecx], 4
        cmp dword [cicle.y_pointer + ecx], 12  ;checking if is necesary reset the movements cicle
        jg restart.cicle.y
        
        continue.y:   ;for come back from the reset

        cmp dword [cicle.y + ebx], 1
        jl move.up
        jg move.down
        ;if there is not movement in x, continue to condition

        condition:  ;the stop condition is reached when all the ships are moved
        add ecx, 4
        cmp ecx, dword [count]  ;compare ecx with the number of blue ships on map * 4
        jl update.x
        jmp working.on.map  ;end cicle

        move.right:        
        add dword [col.offset + ecx] , 1
        jmp update.y

        move.left:
        sub dword [col.offset + ecx] , 1
        jmp update.y

        move.up:
        sub dword [row.offset + ecx] , 1
        jmp condition

        move.down:
        add dword [row.offset + ecx] , 1
        jmp condition

        restart.cicle.x:
        mov dword [cicle.x_pointer + ecx], 0
        jmp continue.x

        restart.cicle.y:
        mov dword [cicle.y_pointer + ecx], 0
        jmp continue.y

        
        working.on.map:

        end:

    FUNC.END

;paint()
;move all the red enemies
global enemy_red.paint
enemy_red.paint:
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

; enemy_red.take_damage(dword damage)
; Takes lives away from an enemy
; returns 0 if player remains alive after damage, 1 otherwise
global enemy_red.take_damage
enemy_red.take_damage:
    FUNC.START
    FUNC.END