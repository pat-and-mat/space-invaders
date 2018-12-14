%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"
%include "hash.inc"
%include "sound.inc"
%include "utils.inc"

extern video.print_at
extern video.print
extern video.clear
extern scan
extern delay
extern weapons.shoot
extern rand
extern actual.score
extern play_lives_enemy_die
extern engine.add_collision
extern player.take_damage
extern player2.take_damage
extern can_move
extern old_map
extern array.index_of
extern player.lives
extern player2.lives
extern arrayd.shiftl

%define SIZE 100
%define BONUS.COORDS 1

section .data

timer dd 0

count dd 0

graphics dd 3|FG.RED|BG.GREEN
            
rows dd 0
cols dd 0

next_inst dd 1

graphics.style db 0

section .bss

;1-moving down 2-moving up
dir resd SIZE

row.offset resd SIZE
col.offset resd SIZE
inst resd SIZE

lives resd SIZE

left.count resd SIZE

timer.lives resd 2

section .text

;init(dw row.offset, dw col.offset)
; Initialize a live
global bonus_lives.init
bonus_lives.init:
    FUNC.START
    RESERVE(1)
    mov edx, HASH.BONUS_LIVES << 16
    mov [LOCAL(0)], edx

    CALL can_move, old_map, [PARAM(0)], [PARAM(1)], rows, cols, BONUS.COORDS, 0, 0, 0, 0, [LOCAL(0)]       
    cmp eax, 0
    je .end

    ;filling local vars
    mov eax, dword [count]    
    shl eax, 2     

    mov edx, [PARAM(0)]
    mov [row.offset + eax], edx 

    mov edx, [PARAM(1)]
    mov [col.offset + eax], edx

    mov dword [lives + eax], 5

    ;pointer of the actual moviment    
    mov dword [left.count + eax], 0

    mov edx, [next_inst]
    mov [inst + eax], edx
    add dword [next_inst], 1

    inc dword [count]   

    .end:
    FUNC.END

;update(dword *map)
;move all the bonus lives
global bonus_lives.update
bonus_lives.update:
    FUNC.START
    RESERVE(4)

    CALL delay, timer.lives, 150  ;timing condition to move
    cmp eax, 0
    je update.map

    cmp dword [count], 0
    je end
   
    mov dword [LOCAL(3)], 0   ;actual bonus

    start:
        mov ecx, [LOCAL(3)]
        shl ecx, 2
        
        mov edx, HASH.BONUS_LIVES << 16
        mov dx, [inst + ecx]
        mov[LOCAL(2)], edx

        cmp dword [left.count + ecx], 3
        je move.left
        add dword [left.count + ecx], 1

        CALL rand, 10
        cmp eax, 5
        jge down
        

        up:
        cmp dword [row.offset + ecx], 2
        jle move.down
        jmp move.up

        down:
        cmp dword [row.offset + ecx], 22
        jge move.up
        jmp move.down

        condition:  ;the stop condition is reached when all the bonus are moved
        inc dword [LOCAL(3)]
        mov ecx, [LOCAL(3)]
        cmp ecx, [count]  ;compare ecx with the number of blue bonus on map
        jl start
        jmp update.map  ;end cicle

        move.right: 
        push ecx
        CALL can_move, old_map, [row.offset + ecx], [col.offset + ecx], rows, cols, BONUS.COORDS, 0, 0, 2, 0, [LOCAL(2)]       
        pop ecx
        cmp eax, 0
        je condition

        add dword [col.offset + ecx] , 2
        jmp condition

        move.left:
        cmp dword [col.offset + ecx] , 1
        jle destroy
        mov dword [left.count + ecx], 0

        push ecx
        CALL can_move, old_map, [row.offset + ecx], [col.offset + ecx], rows, cols, BONUS.COORDS, 0, 0, 0, 1, [LOCAL(2)]
        pop ecx
        cmp eax, 0
        je condition        
        sub dword [col.offset + ecx] , 1
        jmp condition

        move.up:
        push ecx
        CALL can_move, old_map, [row.offset + ecx], [col.offset + ecx], rows, cols, BONUS.COORDS, 0, 1, 0, 0, [LOCAL(2)]
        pop ecx
        cmp eax, 0
        je condition   

        sub dword [row.offset + ecx] , 1
        jmp condition

        move.down:
        push ecx
        CALL can_move, old_map, [row.offset + ecx], [col.offset + ecx], rows, cols, BONUS.COORDS, 1, 0, 0, 0, [LOCAL(2)]
        pop ecx
        cmp eax, 0
        je condition        
        
        add dword [row.offset + ecx] , 1
        jmp condition

        destroy:
        CALL destroy.bonus, [LOCAL(3)]
        dec dword [LOCAL(3)]
        jmp condition

        update.map:
        CALL lives.put_all_in_map, [PARAM(0)]
        end:

    FUNC.END

; lives.put_all_in_map(dword *map)
lives.put_all_in_map:
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

        mov edx, HASH.BONUS_LIVES << 16
        mov dx, [inst + ecx]

        CALL lives.put_one_in_map, [PARAM(0)], edx, [LOCAL(1)], [LOCAL(2)]
        
        inc dword [LOCAL(0)]
        jmp .map.all.while
    .map.all.while.end:
    FUNC.END

; lives.put_one_in_map(dword *map, dword hash, dword row, dword col)
lives.put_one_in_map:
    FUNC.START
    RESERVE(4)  ; coord, offset

    mov dword [LOCAL(0)], 0
    .map.one.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, BONUS.COORDS
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

        CALL engine.add_collision, [PARAM(1)], [eax]

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
global bonus_lives.collision
bonus_lives.collision:
    FUNC.START    
    RESERVE(1)

    CALL array.index_of, inst, ecx, [PARAM(0)], 4 
    mov [LOCAL(0)], eax

    cmp dword [PARAM(1)], HASH.PLAYER
    je crash_player

    cmp dword [PARAM(1)], HASH.PLAYER2
    je crash_player2

    cmp dword [PARAM(1)], HASH.SHOT
    je crash_shoot

    cmp dword [PARAM(1)], HASH.ENEMY_BOSS
    je crash_boss

    cmp dword [PARAM(1)], HASH.ENEMY_METEORO
    je crash_meteoro

    crashed:
    FUNC.END

    crash_player:
    mov word [player.lives], 25
    CALL destroy.bonus, [LOCAL(0)]
    jmp crashed

    crash_player2:
    mov word [player2.lives], 25
    CALL destroy.bonus, [LOCAL(0)]
    jmp crashed

    crash_shoot:
    jmp crashed

    crash_boss:
    CALL destroy.bonus, [LOCAL(0)]
    jmp crashed

    crash_meteoro:
    CALL destroy.bonus, [LOCAL(0)]
    jmp crashed
     FUNC.END

;paint()
;move all the lives
global bonus_lives.paint
bonus_lives.paint:
    FUNC.START
    RESERVE(4)
    
    cmp dword [count], 0
    je while.end
   
    mov dword [LOCAL(2)], 0    
    mov dword [LOCAL(3)], 0

    cmp byte [graphics.style], 1
    je set.form2
    jmp set.form1

    ;painting bonus number LOCAL(2)
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
        cmp ecx, BONUS.COORDS
        jl while.internal   
        ;while end

    ;updating esi
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
        mov dword [graphics], 3|FG.RED|BG.BLACK
        jmp while.internal

    set.form1:
        mov byte [graphics.style], 1
        mov dword [graphics], 3|FG.GREEN|BG.BLACK
        jmp while.internal


;destroy.bonus(dword index)
;destroyes the bonus that is in the index position
destroy.bonus:
    FUNC.START    
    RESERVE(1)
   
    mov eax, [PARAM(0)]
    mov [LOCAL(0)], eax

    CALL arrayd.shiftl, lives, [count], [LOCAL(0)]
    CALL arrayd.shiftl, row.offset, [count], [LOCAL(0)]
    CALL arrayd.shiftl, col.offset, [count], [LOCAL(0)]
    CALL arrayd.shiftl, left.count, [count], [LOCAL(0)]
    CALL arrayd.shiftl, inst, [count], [LOCAL(0)]

    sub dword [count], 1

    FUNC.END


; bonus_lives.reset()
; reset the lives enemies
global bonus_lives.reset
bonus_lives.reset:
    FUNC.START
    mov dword[count], 0
    FUNC.END