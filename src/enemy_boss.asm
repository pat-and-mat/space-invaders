%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"
%include "hash.inc"
%include "sound.inc"
%include "utils.inc"

extern arrayd.shiftl
extern video.print
extern delay
extern weapons.shoot
extern rand
extern actual.score
extern play_boss_enemy_die
extern engine.add_collision
extern player.take_damage
extern player2.take_damage
extern ai.take_damage
extern can_move
extern old_map
extern array.index_of
extern enemy_blue.take_damage
extern enemy_red.take_damage
extern enemy_yellow.take_damage
extern enemy_meteoro.take_damage

%define SIZE 10
%define SHIP.COORDS 28

section .data

timer dd 0

count dd 0

graphics dd ' '|FG.BRIGHT|BG.BLACK, '_'|FG.BRIGHT|BG.BLACK, '_'|FG.BRIGHT|BG.BLACK, '_'|FG.BRIGHT|BG.BLACK, '_'|FG.BRIGHT|BG.BLACK, '_'|FG.BRIGHT|BG.BLACK, ' '|FG.BRIGHT|BG.BLACK,\
            '|'|FG.BRIGHT|BG.BLACK, ' '|FG.BRIGHT|BG.BLACK, '\'|FG.BRIGHT|BG.BLACK, ' '|FG.BRIGHT|BG.BLACK, '/'|FG.BRIGHT|BG.BLACK, ' '|FG.BRIGHT|BG.BLACK, '|'|FG.BRIGHT|BG.BLACK,\
            '|'|FG.BRIGHT|BG.BLACK, ' '|FG.BRIGHT|BG.BLACK, 'o'|FG.BRIGHT|BG.BLACK, ' '|FG.BRIGHT|BG.BLACK, 'O'|FG.BRIGHT|BG.BLACK, ' '|FG.BRIGHT|BG.BLACK, '|'|FG.BRIGHT|BG.BLACK,\
            '|'|FG.BRIGHT|BG.BLACK, '_'|FG.BRIGHT|BG.BLACK, '-'|FG.BRIGHT|BG.BLACK, '-'|FG.BRIGHT|BG.BLACK, '-'|FG.BRIGHT|BG.BLACK, '_'|FG.BRIGHT|BG.BLACK, '|'|FG.BRIGHT|BG.BLACK,
            
            
            
rows dd 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3
cols dd 0, 1, 2, 3, 4, 5, 6, 0, 1, 2, 3, 4, 5, 6, 0, 1, 2, 3, 4, 5, 6, 0, 1, 2, 3, 4, 5, 6

weapon1.row dd 4
weapon1.col dd 2
weapon2.row dd 4
weapon2.col dd 5
next_inst dd 1

graphics.style db 0

section .bss

;1-moving right 2-moving left
dir resd SIZE

row.offset resd SIZE
col.offset resd SIZE
inst resd SIZE

lives resd SIZE

down.count resd SIZE

timer.boss resd 2
timer.debug resd 2
animation.timer resd 2

section .text

;init(dw row.offset, dw col.offset)
; Initialize a boss enemy
global enemy_boss.init
enemy_boss.init:
    FUNC.START
    RESERVE(1)
    mov edx, HASH.ENEMY_BOSS << 16
    mov [LOCAL(0)], edx

    ;filling local vars
    mov eax, dword [count]    
    shl eax, 2     

    mov edx, [PARAM(0)]
    mov [row.offset + eax], edx 

    mov edx, [PARAM(1)]
    mov [col.offset + eax], edx

    mov dword [lives + eax], 20

    ;pointer of the actual moviment    
    mov dword [down.count + eax], 0

    mov edx, [next_inst]
    mov [inst + eax], edx
    add dword [next_inst], 1

    inc dword [count]   

    .end:
    FUNC.END

;update(dword *map)
;move all the blue enemies
global enemy_boss.update
enemy_boss.update:
    FUNC.START
    RESERVE(4)
    cmp dword [count], 0
    je end
   
    CALL delay, timer.boss, 800  ;timing condition to move
    cmp eax, 0
    je update.map
    
    mov dword [LOCAL(3)], 0   ;actual ship

    start:
        mov ecx, [LOCAL(3)]
        shl ecx, 2
        CALL rand, 2
        cmp eax, 0
        je boss.shoot
        after.shoot:

        mov edx, HASH.ENEMY_BOSS << 16
        mov dx, [inst + ecx]
        mov[LOCAL(2)], edx

        cmp dword [down.count + ecx], 7
        je move.down
        add dword [down.count + ecx], 1

        CALL rand, 10
        cmp eax, 5
        jge right
        

        left:
        cmp dword [col.offset + ecx], 10
        jle move.right
        jmp move.left

        right:
        cmp dword [col.offset + ecx], 70
        jge move.left
        jmp move.right

        condition:  ;the stop condition is reached when all the ships are moved
                
        inc dword [LOCAL(3)]
        mov ecx, [LOCAL(3)]
        cmp ecx, [count]  ;compare ecx with the number of blue ships on map
        jl start
        jmp update.map  ;end cicle

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
        ; check position
        cmp dword [row.offset + ecx] , 18
        jge destroy
                
        add dword [row.offset + ecx] , 1
        mov dword [down.count + ecx], 0
        jmp condition

        destroy:
        CALL destroy.ship, [LOCAL(3)]
        dec dword [LOCAL(3)]
        jmp condition

        boss.shoot:
        mov eax, [weapon1.row]
        add eax, [row.offset + ecx]
        add eax, 1
        mov [LOCAL(0)], eax

        mov eax, [weapon1.col]
        add eax, [col.offset + ecx]
        mov [LOCAL(1)], eax
        push ecx
        CALL weapons.shoot, [LOCAL(0)], [LOCAL(1)], 0
        pop ecx

        mov eax, [weapon2.row]
        add eax, [row.offset + ecx]
        add eax, 1
        mov [LOCAL(0)], eax

        mov eax, [weapon2.col]
        add eax, [col.offset + ecx]
        mov [LOCAL(1)], eax
        push ecx
        CALL weapons.shoot, [LOCAL(0)], [LOCAL(1)], 0
        pop ecx
        jmp after.shoot       
        
        update.map:
        CALL boss.put_all_in_map, [PARAM(0)]
        end:

    FUNC.END

; boss.put_all_in_map(dword *map)
boss.put_all_in_map:
    FUNC.START
    RESERVE(3) ; i, row, col
    cmp dword [count], 0
    je .map.all.while.end

    mov dword [LOCAL(0)], 0
    .map.all.while:
        mov ecx, [LOCAL(0)]
        
        cmp ecx, [count]
        je .map.all.while.end

        shl ecx, 2

        mov eax, [row.offset + ecx]
        mov [LOCAL(1)], eax

        mov eax, [col.offset + ecx]
        mov [LOCAL(2)], eax

        mov edx, HASH.ENEMY_BOSS << 16
        mov dx, [inst + ecx]

        CALL boss.put_one_in_map, [PARAM(0)], edx, [LOCAL(1)], [LOCAL(2)]
        
        inc dword [LOCAL(0)]
        jmp .map.all.while
    .map.all.while.end:
    FUNC.END

; boss.put_one_in_map(dword *map, dword hash, dword row, dword col)
boss.put_one_in_map:
    FUNC.START
    RESERVE(5)  ; coord, offset
    
    mov dword [LOCAL(4)], 0
    mov dword [LOCAL(0)], 0
    .map.one.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, SHIP.COORDS
        je .map.one.while.end

        shl ecx, 2
        
        mov eax, [rows + ecx]
        mov edx, [PARAM(2)]
        mov [LOCAL(2)], edx
        add [LOCAL(2)], eax
        
        mov eax, [cols + ecx]
        mov edx, [PARAM(3)]
        mov [LOCAL(3)], edx
        add [LOCAL(3)], eax

        OFFSET [LOCAL(2)], [LOCAL(3)]

        mov [LOCAL(1)], eax
        shl eax, 2
        add eax, [PARAM(0)]

        cmp dword [eax], 0
        je .map.one.while.cont
        
        mov ebx, [eax]
        mov [LOCAL(4)], ebx

        CALL engine.add_collision, [PARAM(1)], [LOCAL(4)]

        .map.one.while.cont:
            mov eax, [LOCAL(1)]

            shl eax, 2
            add eax, [PARAM(0)]

            mov edx, [PARAM(1)]
            mov [eax], edx
            inc dword [LOCAL(0)]
            jmp .map.one.while
    .map.one.while.end:

    FUNC.END

; collision(dword inst, dword hash_other, dword inst_other)
; It is here where collisions will be handled
global enemy_boss.collision
enemy_boss.collision:
    FUNC.START
    cmp dword [PARAM(1)], HASH.PLAYER
    je crash_player

    cmp dword [PARAM(1)], HASH.PLAYER2
    je crash_player2

    cmp dword [PARAM(1)], HASH.SHOT
    je crash_shoot

    cmp dword [PARAM(1)], HASH.ENEMY_BLUE
    je crash_blue

    cmp dword [PARAM(1)], HASH.ENEMY_RED
    je crash_red

    cmp dword [PARAM(1)], HASH.ENEMY_YELLOW
    je crash_yellow

    cmp dword [PARAM(1)], HASH.ENEMY_METEORO
    je crash_meteoro

    cmp dword [PARAM(1)], HASH.AI
    je crash_ai
    
    crashed:
    FUNC.END

    crash_player:
    CALL player.take_damage, 25
    jmp crashed

    crash_player2:
    CALL player2.take_damage, 25
    jmp crashed

    crash_shoot:
    jmp crashed

    crash_blue:
    CALL enemy_blue.take_damage, 1, [PARAM(2)]
    jmp crashed

    crash_red:
    CALL enemy_red.take_damage, 1, [PARAM(2)]
    jmp crashed

    crash_yellow:
    CALL enemy_yellow.take_damage, 1, [PARAM(2)]
    jmp crashed

    crash_meteoro:
    CALL enemy_meteoro.take_damage, 20, [PARAM(2)]
    jmp crashed

    crash_ai:
    CALL ai.take_damage, 25, [PARAM(2)]
    jmp crashed

;paint()
;paint all the boss enemies
global enemy_boss.paint
enemy_boss.paint:
    FUNC.START
    RESERVE(5)
    
    cmp dword [count], 0
    je while.end
   
    mov dword [LOCAL(2)], 0    
    mov dword [LOCAL(3)], 0

    CALL delay, animation.timer, 250   ;the form of the ship change every 100ms
    cmp eax, 0
    je while.internal

    cmp byte [graphics.style], 1
    je set.form2
    jmp set.form1

    ;painting ship number LOCAL(2)    
    while.internal:           
        
        mov ecx, [LOCAL(3)]
        shl ecx, 2
        mov ebx, [LOCAL(2)]
        shl ebx, 2

        mov eax, [row.offset + ebx]
        add eax, [rows + ecx]
        mov [LOCAL(0)], eax

        mov eax, [col.offset + ebx]
        add eax, [cols + ecx]
        mov [LOCAL(1)], eax
        
        CALL video.print, [graphics + ecx], [LOCAL(0)], [LOCAL(1)]

        inc dword [LOCAL(3)]
        mov ecx, [LOCAL(3)]
        cmp ecx, SHIP.COORDS
        jl while.internal   

    while.external:
        mov dword [LOCAL(3)], 0  
        inc dword [LOCAL(2)]
        mov eax, [LOCAL(2)]
        cmp eax, dword [count]
        jl while.internal
        while.end:
    FUNC.END

    set.form2:
        mov byte [graphics.style], 0
        mov dword [graphics + 64], 'O'|FG.BRIGHT|BG.BLACK
        mov dword [graphics + 72], 'o'|FG.BRIGHT|BG.BLACK
        mov dword [graphics + 92], 'X'|FG.BRIGHT|BG.BLACK
        mov dword [graphics + 96], 'X'|FG.BRIGHT|BG.BLACK
        mov dword [graphics + 100], 'X'|FG.BRIGHT|BG.BLACK
        jmp while.internal

    set.form1:
        mov byte [graphics.style], 1
        mov dword [graphics + 64], 'o'|FG.BRIGHT|BG.BLACK
        mov dword [graphics + 72], 'O'|FG.BRIGHT|BG.BLACK
        mov dword [graphics + 92], '-'|FG.BRIGHT|BG.BLACK
        mov dword [graphics + 96], '-'|FG.BRIGHT|BG.BLACK
        mov dword [graphics + 100], '-'|FG.BRIGHT|BG.BLACK
        jmp while.internal

; enemy_boss.take_damage(dword damage, dword instance)
; Takes lives away from an enemy
global enemy_boss.take_damage
enemy_boss.take_damage:
    FUNC.START
    RESERVE(1)

    mov ecx, [count]
    CALL array.index_of, inst, ecx, [PARAM(1)], 4 
    mov [LOCAL(0)], eax
    shl eax, 2

    mov ecx, [PARAM(0)]    
    cmp dword [lives + eax], ecx
    jg .take_end

    add dword [actual.score], 5000
    mov eax, [LOCAL(0)]
    CALL destroy.ship, eax
    mov eax, 0
    jmp .take_damage.end

    .take_end:
    sub [lives + eax], ecx

    mov eax, [lives + eax]
    .take_damage.end:
    FUNC.END

;destroy.ship(dword index)
;destroyes the ship that is in the index position
destroy.ship:
    FUNC.START   
    RESERVE(1) 

    call play_boss_enemy_die

    mov eax, [PARAM(0)]
    mov [LOCAL(0)], eax
    
    CALL arrayd.shiftl, lives, [count], [LOCAL(0)]
    CALL arrayd.shiftl, row.offset, [count], [LOCAL(0)]
    CALL arrayd.shiftl, col.offset, [count], [LOCAL(0)]
    CALL arrayd.shiftl, down.count, [count], [LOCAL(0)]
    CALL arrayd.shiftl, inst, [count], [LOCAL(0)]

    sub dword [count], 1
    FUNC.END


; enemy_boss.reset()
; reset the boss enemies
global enemy_boss.reset
enemy_boss.reset:
    FUNC.START
    mov dword[count], 0
    FUNC.END 
