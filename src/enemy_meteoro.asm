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
extern play_meteoro_enemy_die
extern engine.add_collision
extern player.take_damage
extern ai.take_damage
extern can_move
extern old_map
extern array.index_of
extern enemy_red.take_damage
extern enemy_blue.take_damage
extern enemy_yellow.take_damage
extern arrayd.shiftl



%define SIZE 10
%define meteoro.COORDS 20

section .data

timer dd 0

count dd 0

graphics dd ' '|FG.RED|BG.BLACK, 'w'|FG.RED|BG.BLACK, 'W'|FG.RED|BG.BLACK, 'w'|FG.RED|BG.BLACK, ' '|FG.RED|BG.BLACK,\
            'w'|FG.RED|BG.BLACK, 'W'|FG.RED|BG.BLACK, 'w'|FG.RED|BG.BLACK, 'W'|FG.RED|BG.BLACK, 'w'|FG.RED|BG.BLACK,\
            '/'|FG.GRAY|BG.BLACK, ' '|FG.GRAY|BG.BLACK, ' '|FG.GRAY|BG.BLACK, ' '|FG.GRAY|BG.BLACK, '\'|FG.GRAY|BG.BLACK,\
            '\'|FG.GRAY|BG.BLACK, '_'|FG.GRAY|BG.BLACK, '_'|FG.GRAY|BG.BLACK, '_'|FG.GRAY|BG.BLACK, '/'|FG.GRAY|BG.BLACK, 
            
            
            
rows dd 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3,
cols dd 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4,

next_inst dd 1

graphics.style db 0

section .bss

row.offset resd SIZE
col.offset resd SIZE
inst resd SIZE

lives resd SIZE

timer.meteoro resd 2

animation.timer resd 2

section .text

;init(dw row.offset, dw col.offset)
; Initialize a meteoro enemy
global enemy_meteoro.init
enemy_meteoro.init:
    FUNC.START
    RESERVE(1)
    mov edx, HASH.ENEMY_METEORO << 16
    mov [LOCAL(0)], edx

    ; CALL can_move, old_map, [PARAM(0)], [PARAM(1)], rows, cols, meteoro COORDS, 0, 0, 0, 0, [LOCAL(0)]       
    ; cmp eax, 0
    ; je .end

    ;filling local vars
    mov eax, dword [count]    
    shl eax, 2     

    mov edx, [PARAM(0)]
    mov [row.offset + eax], edx 

    mov edx, [PARAM(1)]
    mov [col.offset + eax], edx

    mov dword [lives + eax], 20

    mov edx, [next_inst]
    mov [inst + eax], edx
    add dword [next_inst], 1

    inc dword [count]   

    .end:
    FUNC.END

;update(dword *map)
;move all the blue enemies
global enemy_meteoro.update
enemy_meteoro.update:
    FUNC.START
    RESERVE(2)
    cmp dword [count], 0
    je end

    CALL delay, timer.meteoro, 400  ;timing condition to move
    cmp eax, 0
    je working.on.map
   
    mov dword [LOCAL(1)], 0   ;actual meteoro 
    start:
        mov ecx, [LOCAL(1)]
        shl ecx, 2
        
        mov edx, HASH.ENEMY_METEORO << 16
        mov dx, [inst + ecx]
        mov[LOCAL(0)], edx

        jmp move.down        
        condition:  ;the stop condition is reached when all the meteoro  are moved
        inc dword [LOCAL(1)]
        mov ecx, [LOCAL(1)]
        cmp ecx, [count]  ;compare ecx with the number of blue meteoro  on map
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
        cmp dword [row.offset + ecx], 21
        jge destroy
        ; push ecx
        ; CALL can_move, old_map, [row.offset + ecx], [col.offset + ecx], rows, cols, meteoro COORDS, 1, 0, 0, 0, [LOCAL(2)]
        ; pop ecx
        ; cmp eax, 0
        ; je condition
                
        add dword [row.offset + ecx] , 1
        jmp condition

        destroy:
        CALL destroy.meteoro, [LOCAL(1)]
        dec dword [LOCAL(1)]
        jmp condition

        working.on.map:
        CALL meteoro.put_all_in_map, [PARAM(0)]
        end:

    FUNC.END

; meteoro.put_all_in_map(dword *map)
meteoro.put_all_in_map:
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

        mov edx, HASH.ENEMY_METEORO << 16
        mov dx, [inst + ecx]

        CALL meteoro.put_one_in_map, [PARAM(0)], edx, [LOCAL(1)], [LOCAL(2)]
        
        inc dword [LOCAL(0)]
        jmp .map.all.while
    .map.all.while.end:
    FUNC.END

; meteoro.put_one_in_map(dword *map, dword hash, dword row, dword col)
meteoro.put_one_in_map:
    FUNC.START
    RESERVE(4)  ; coord, offset

    mov dword [LOCAL(0)], 0
    .map.one.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, meteoro.COORDS
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
global enemy_meteoro.collision
enemy_meteoro.collision:
    FUNC.START    

    cmp dword [PARAM(1)], HASH.PLAYER
    je crash_player

    cmp dword [PARAM(1)], HASH.SHOT
    je crash_shoot

    cmp dword [PARAM(1)], HASH.ENEMY_BLUE
    je crash_blue

    cmp dword [PARAM(1)], HASH.ENEMY_RED
    je crash_red

    cmp dword [PARAM(1)], HASH.ENEMY_YELLOW
    je crash_yellow

    cmp dword [PARAM(1)], HASH.ENEMY_BOSS
    je crash_boss

    cmp dword [PARAM(1)], HASH.AI
    je crash_ai
    
    crashed:
    FUNC.END

    crash_player:
    CALL player.take_damage, 25
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
    
    crash_boss:
    jmp crashed

    crash_ai:
    CALL ai.take_damage, 25
    jmp crashed

    FUNC.END

;paint()
;paint all the meteoro enemies
global enemy_meteoro.paint
enemy_meteoro.paint:
    FUNC.START
    RESERVE(4)
    
    cmp dword [count], 0
    je while.end
   
    mov dword [LOCAL(2)], 0    
    mov dword [LOCAL(3)], 0

    CALL delay, animation.timer, 100   ;the form of the meteoro change every 100ms
    cmp eax, 0
    je while.internal

    cmp byte [graphics.style], 1
    je set.form2
    jmp set.form1

    
    ;painting meteoro number LOCAL(2)
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
        cmp ecx, meteoro.COORDS
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
        mov dword [graphics + 4], 'W'|FG.RED|BG.BLACK
        mov dword [graphics + 8], 'w'|FG.RED|BG.BLACK
        mov dword [graphics + 12], 'W'|FG.RED|BG.BLACK
        mov dword [graphics + 20], 'W'|FG.RED|BG.BLACK
        mov dword [graphics + 24], 'w'|FG.RED|BG.BLACK
        mov dword [graphics + 28], 'W'|FG.RED|BG.BLACK
        mov dword [graphics + 32], 'w'|FG.RED|BG.BLACK
        mov dword [graphics + 36], 'W'|FG.RED|BG.BLACK
        jmp while.internal

    set.form1:
        mov byte [graphics.style], 1
        mov dword [graphics + 4], 'w'|FG.RED|BG.BLACK
        mov dword [graphics + 8], 'W'|FG.RED|BG.BLACK
        mov dword [graphics + 12], 'w'|FG.RED|BG.BLACK
        mov dword [graphics + 20], 'w'|FG.RED|BG.BLACK
        mov dword [graphics + 24], 'W'|FG.RED|BG.BLACK
        mov dword [graphics + 28], 'w'|FG.RED|BG.BLACK
        mov dword [graphics + 32], 'W'|FG.RED|BG.BLACK
        mov dword [graphics + 36], 'w'|FG.RED|BG.BLACK
        jmp while.internal

; enemy_meteoro.take_damage(dword damage, dword instance)
; Takes lives away from an enemy
global enemy_meteoro.take_damage
enemy_meteoro.take_damage:
    FUNC.START
    RESERVE(1)

    mov ecx, [count]
    CALL array.index_of, inst, ecx, [PARAM(1)], 4 
    mov [LOCAL(0)], eax
    shl eax, 2

    mov ecx, [PARAM(0)]    
    cmp dword [lives + eax], ecx
    jg take_end

    add dword [actual.score], 50
    mov eax, [LOCAL(0)]
    CALL destroy.meteoro, eax
    mov eax, 0
    jmp take_damage.end

    take_end:
    sub [lives + eax], ecx

    mov eax, [lives + eax]
    take_damage.end:
    FUNC.END

;destroy.meteoro dword index)
;destroyes the meteoro that is in the index position
destroy.meteoro: 
    FUNC.START
    RESERVE(1)    

    ; call play_meteoro_enemy_die

    mov eax, [PARAM(0)]
    mov [LOCAL(0)], eax
    
    CALL arrayd.shiftl, lives, [count], [LOCAL(0)]
    CALL arrayd.shiftl, row.offset, [count], [LOCAL(0)]
    CALL arrayd.shiftl, col.offset, [count], [LOCAL(0)]
    CALL arrayd.shiftl, inst, [count], [LOCAL(0)]

    sub dword [count], 1
    FUNC.END


; enemy_meteoro.reset()
; reset the meteoro enemies
global enemy_meteoro.reset
enemy_meteoro.reset:
    FUNC.START
    mov dword[count], 0
    FUNC.END