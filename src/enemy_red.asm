%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"
%include "hash.inc"
%include "sound.inc"

extern video.print_at
extern video.print
extern video.clear
extern scan
extern delay
extern rand
extern weapons.shoot
extern play_red_enemy_die


;each ship will have 4 parts, that's why it's reserved space for 500 ships(COLS * ROWS / 4)
%define ZIZE 500
%define SHIP.COORDS 3

section .data

timer dd 0

count dd 0

graphics dd 'o'|FG.RED|BG.BLACK,\
            'o'|FG.RED|BG.BLACK,\
            '='|FG.RED|BG.BLACK,\
            
rows dd 0, 0, 0
cols dd 0, 2, 1

row.top dd 0
row.bottom dd 0

col.left dd 0
col.right dd 3

weapon.row dd 1
weapon.col dd 1

hash dd 3

graphics.style db 0

section .bss

;1-moving right 2-moving left
dir resd ZIZE

row.offset resd ZIZE
col.offset resd ZIZE

lives resd ZIZE

down.count resd ZIZE

timer.red resd 2

animation.timer resd 2

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
    mov dword [down.count + eax], 0

    add dword [count], 4   

    FUNC.END

;update()
;move all the blue enemies
global enemy_red.update
enemy_red.update:
    FUNC.START
    RESERVE(2)

    CALL delay, timer.red, 250  ;timing condition to move
    cmp eax, 0
    je working.on.map

    cmp dword [count], 0
    je working.on.map
   
    mov ecx, 0

    start:
        CALL rand, 65
        cmp eax, 0
        je red.shoot
        after.shoot:
        cmp dword [down.count + ecx], 7
        je move.down
        add dword [down.count + ecx], 1

        CALL rand, 10
        cmp eax, 4
        jge right
        

        left:
        cmp dword [col.offset + ecx], 0
        je move.right
        cmp dword [col.offset + ecx], 1
        je move.right
        cmp dword [col.offset + ecx], 2
        je move.right
        jmp move.left

        right:
        cmp dword [col.offset + ecx], 77
        je move.left
        cmp dword [col.offset + ecx], 76
        je move.left
        cmp dword [col.offset + ecx], 75
        je move.left
        jmp move.right

        condition:  ;the stop condition is reached when all the ships are moved
        add ecx, 4
        cmp ecx, dword [count]  ;compare ecx with the number of blue ships on map * 4
        jl start
        jmp working.on.map  ;end cicle

        move.right:        
        add dword [col.offset + ecx] , 2
        jmp condition

        move.left:
        sub dword [col.offset + ecx] , 2
        jmp condition

        move.up:
        sub dword [row.offset + ecx] , 1
        jmp condition

        move.down:
        ;check position

        cmp dword [row.offset + ecx] , 24
        jge destroy
        mov dword [down.count + ecx], 0
        add dword [row.offset + ecx] , 1

        jmp condition

        destroy:
        CALL destroy.ship, ecx
        sub ecx, 4
        jmp condition

        red.shoot:
        mov eax, [weapon.row]
        add eax, [row.offset + ecx]
        sub eax, 1
        mov [LOCAL(0)], eax

        mov eax, [weapon.col]
        add eax, [col.offset + ecx]
        mov [LOCAL(1)], eax
        push ecx
        CALL weapons.shoot, [LOCAL(0)], [LOCAL(1)], 0
        pop ecx
        jmp after.shoot

        
        
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

    CALL delay, animation.timer, 100   ;the form of the ship change every 100ms
    cmp eax, 0
    je while.internal

    cmp byte [graphics.style], 1
    je set.form2
    jmp set.form1

    
    ;painting ship number esi * 4
    while.internal:           
        mov eax, [row.offset + esi]
        add eax, [rows + ecx]
        mov [LOCAL(0)], eax

        mov eax, [col.offset + esi]
        add eax, [cols + ecx]
        mov [LOCAL(1)], eax

        CALL video.print, [graphics + ecx], [LOCAL(0)], [LOCAL(1)]
        add ecx, 4
        cmp ecx, SHIP.COORDS * 4
        jl while.internal

    ;updating esi
    while.external:
        mov ecx, 0  
        add esi, 4
        cmp esi, dword [count]
        jl while.internal
        while.end:
    FUNC.END

    set.form2:
        mov byte [graphics.style], 0
        mov dword [graphics + 8], '-'|FG.RED|BG.BLACK
        jmp while.internal

    set.form1:
        mov byte [graphics.style], 1
        mov dword [graphics + 8], '='|FG.RED|BG.BLACK
        jmp while.internal

; enemy_red.take_damage(dword damage)
; Takes lives away from an enemy
; returns 0 if player remains alive after damage, 1 otherwise
global enemy_red.take_damage
enemy_red.take_damage:
    FUNC.START
    FUNC.END

;destroy.ship(dword index)
;destroyes the ship that is in the index position
destroy.ship:
    FUNC.START
    call play_red_enemy_die

    mov eax, [PARAM(0)]
    while:
        cmp eax, dword [count]
        je end.while
        mov ebx, [lives + eax + 4]
        mov dword [lives + eax], ebx
        mov ebx, [row.offset + eax + 4]
        mov dword [row.offset + eax], ebx
        mov ebx, [col.offset + eax + 4]
        mov dword [col.offset + eax], ebx
        mov ebx, [down.count + eax + 4]
        mov dword [down.count + eax], ebx
        add eax, 4
        jmp while

    end.while:

    sub dword [count], 4

    FUNC.END