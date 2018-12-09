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
extern engine.add_collision
extern player.take_damage
extern can_move
extern old_map
extern array.index_of


%define SIZE 500
%define BONUS.COORDS 1

section .data

timer dd 0

count dd 0

graphics dd 5|FG.YELLOW|BG.BLACK,\
            
            
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

timer.weapon1 resd 2

section .text

;init(dw row.offset, dw col.offset)
; Initialize a weapon1
global bonus_weapon1.init
bonus_weapon1.init:
    FUNC.START
    RESERVE(1)
    mov edx, HASH.BONUS_WEAPON1 << 16
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

    mov dword [lives + eax], 10

    ;pointer of the actual moviment    
    mov dword [left.count + eax], 0

    mov edx, [next_inst]
    mov [inst + eax], edx
    add dword [next_inst], 1

    inc dword [count]   

    .end:
    FUNC.END

;update(dword *map)
;move all the bonus weapon1
global bonus_weapon1.update
bonus_weapon1.update:
    FUNC.START
    RESERVE(4)

    CALL delay, timer.weapon1, 150  ;timing condition to move
    cmp eax, 0
    je working.on.map

    cmp dword [count], 0
    je end
   
    mov dword [LOCAL(3)], 0   ;actual bonus

    start:
        mov ecx, [LOCAL(3)]
        shl ecx, 2
        
        mov edx, HASH.BONUS_WEAPON1 << 16
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
        cmp ecx, [count]  ;compare ecx with the number of weapon1 bonus on map
        jl start
        jmp working.on.map  ;end cicle

        move.right: 
        push ecx
        CALL can_move, old_map, [row.offset + ecx], [col.offset + ecx], rows, cols, BONUS.COORDS, 0, 0, 1, 0, [LOCAL(2)]       
        pop ecx
        cmp eax, 0
        je condition        
        
        add dword [col.offset + ecx] , 1
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
        CALL destroy.bonus, ecx
        sub ecx, 4
        jmp condition

        working.on.map:
        CALL weapon1.put_all_in_map, [PARAM(0)]
        end:

    FUNC.END

; weapon1.put_all_in_map(dword *map)
weapon1.put_all_in_map:
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

        mov edx, HASH.BONUS_WEAPON1 << 16
        mov dx, [inst + ecx]

        CALL weapon1.put_one_in_map, [PARAM(0)], edx, [LOCAL(1)], [LOCAL(2)]
        
        inc dword [LOCAL(0)]
        jmp .map.all.while
    .map.all.while.end:
    FUNC.END

; weapon1.put_one_in_map(dword *map, dword hash, dword row, dword col)
weapon1.put_one_in_map:
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
        ; CALL video.print, 'X'|FG.GREEN|BG.YELLOW, [LOCAL(2)], [LOCAL(3)]
        ; call video.refresh

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
global bonus_weapon1.collision
bonus_weapon1.collision:
    FUNC.START    
    cmp dword [PARAM(1)], HASH.PLAYER
    je crash_player

    cmp dword [PARAM(1)], HASH.SHOT
    je crash_shoot

    cmp dword [PARAM(1)], HASH.ENEMY_BOSS
    je crash_boss

    cmp dword [PARAM(1)], HASH.ENEMY_METEORO
    je crash_meteoro

    crashed:
    FUNC.END

    crash_player:

    jmp crashed

    crash_shoot:
    jmp crashed

    crash_boss:
    jmp crashed

    crash_meteoro:
    jmp crashed
     FUNC.END

;paint()
;move all the weapon1s
global bonus_weapon1.paint
bonus_weapon1.paint:
    FUNC.START
    RESERVE(4)
    
    cmp dword [count], 0
    je while.end
   
    mov dword [LOCAL(2)], 0    
    mov dword [LOCAL(3)], 0

    ; CALL delay, animation.timer, 100   ;the form of the bonus change every 100ms
    ; cmp eax, 0
    ; je while.internal

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
        mov dword [graphics], 5|FG.YELLOW|BG.BLACK
        jmp while.internal

    set.form1:
        mov byte [graphics.style], 1
        mov dword [graphics], 5|FG.BLUE|BG.BLACK
        jmp while.internal

; bonus_weapon1.take_damage(dword damage, dword instance)
; Takes weapon1 away from an enemy
global bonus_weapon1.take_damage
bonus_weapon1.take_damage:
    FUNC.START
    RESERVE(1)

    mov ecx, [count]
    CALL array.index_of, inst, ecx, [PARAM(1)], 4 
    mov [LOCAL(0)], eax
    shl eax, 2
    mov ecx, [PARAM(0)]

    
    cmp dword [lives + eax], ecx
    jg take_end
    ; add dword [actual.score], 100
    mov eax, [LOCAL(0)]
    CALL destroy.bonus, eax

    take_end:
    sub [lives + eax], ecx
    FUNC.END

;destroy.bonus(dword index)
;destroyes the bonus that is in the index position
destroy.bonus:
    FUNC.START    

   mov eax, [PARAM(0)]
    mov [LOCAL(0)], eax
    while:
        ;move forward the elements of all the arrays
        mov eax, [LOCAL(0)]
        cmp eax, dword [count]
        je end.while

        shl eax, 2
        mov ebx, [lives + eax + 4]
        mov dword [lives + eax], ebx
        mov ebx, [row.offset + eax + 4]
        mov dword [row.offset + eax], ebx
        mov ebx, [col.offset + eax + 4]
        mov dword [col.offset + eax], ebx
        mov ebx, [left.count + eax + 4]
        mov dword [left.count + eax], ebx
        mov ebx, [inst + eax + 4]
        mov dword [inst + eax], ebx

        inc dword [LOCAL(0)]
        jmp while

    end.while:

    sub dword [count], 1
    FUNC.END


; bonus_weapon1.reset()
; reset the weapon1 enemies
global bonus_weapon1.reset
bonus_weapon1.reset:
    FUNC.START
    mov dword[count], 0
    FUNC.END