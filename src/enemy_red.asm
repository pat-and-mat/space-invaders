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
extern play_red_enemy_die
extern engine.add_collision
extern player.take_damage
extern can_move
extern old_map
extern array.index_of


;each ship will have 4 parts, that's why it's reserved space for 500 ships(COLS * ROWS / 4)
%define SIZE 500
%define SHIP.COORDS 3

section .data

timer dd 0

count dd 0

graphics dd 'o'|FG.RED|BG.BLACK,\
            'o'|FG.RED|BG.BLACK,\
            '='|FG.RED|BG.BLACK,\
            
rows dd 0, 0, 0
cols dd 0, 2, 1

col.left dd 0
col.right dd 3

weapon.row dd 1
weapon.col dd 1
next_inst dd 1

hash dd 3

graphics.style db 0

section .bss

;1-moving right 2-moving left
dir resd SIZE

row.offset resd SIZE
col.offset resd SIZE
inst resd SIZE

lives resd SIZE

down.count resd SIZE

timer.red resd 2

animation.timer resd 2

section .text

;init(dw row.offset, dw col.offset)
; Initialize a red enemy
global enemy_red.init
enemy_red.init:
    FUNC.START
    RESERVE(1)
    mov edx, HASH.ENEMY_RED << 16
    mov [LOCAL(0)], edx

    CALL can_move, old_map, [PARAM(0)], [PARAM(1)], rows, cols, SHIP.COORDS, 0, 0, 0, 0, [LOCAL(0)]       
    cmp eax, 0
    je .end

    ;filling local vars
    mov eax, dword [count]    
    shl eax, 2     

    mov edx, [PARAM(0)]
    mov [row.offset + eax], edx 

    mov edx, [PARAM(1)]
    mov [col.offset + eax], edx

    mov dword [lives + eax], 1

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
global enemy_red.update
enemy_red.update:
    FUNC.START
    RESERVE(4)

    CALL delay, timer.red, 250  ;timing condition to move
    cmp eax, 0
    je working.on.map

    cmp dword [count], 0
    je end
   
    mov dword [LOCAL(3)], 0   ;actual ship

    start:
        mov ecx, [LOCAL(3)]
        shl ecx, 2
        CALL rand, 35
        cmp eax, 0
        je red.shoot
        after.shoot:

        mov edx, HASH.ENEMY_RED << 16
        mov dx, [inst + ecx]
        mov[LOCAL(2)], edx

        cmp dword [down.count + ecx], 7
        je move.down
        add dword [down.count + ecx], 1

        CALL rand, 10
        cmp eax, 4
        jge right
        

        left:
        cmp dword [col.offset + ecx], 2
        jle move.right
        jmp move.left

        right:
        cmp dword [col.offset + ecx], 76
        jge move.left
        jmp move.right

        condition:  ;the stop condition is reached when all the ships are moved
        inc dword [LOCAL(3)]
        mov ecx, [LOCAL(3)]
        cmp ecx, [count]  ;compare ecx with the number of blue ships on map
        jl start
        jmp working.on.map  ;end cicle

        move.right: 
        push ecx
        CALL can_move, old_map, [row.offset + ecx], [col.offset + ecx], rows, cols, SHIP.COORDS, 0, 0, 2, 0, [LOCAL(2)]       
        pop ecx
        cmp eax, 0
        je condition

        add dword [col.offset + ecx] , 2
        jmp condition

        move.left:
        push ecx
        CALL can_move, old_map, [row.offset + ecx], [col.offset + ecx], rows, cols, SHIP.COORDS, 0, 0, 0, 2, [LOCAL(2)]
        pop ecx
        cmp eax, 0
        je condition

        sub dword [col.offset + ecx] , 2
        jmp condition

        move.up:
        sub dword [row.offset + ecx] , 1
        jmp condition

        move.down:
        ;check position
        cmp dword [row.offset + ecx] , 24
        jge destroy

        push ecx
        CALL can_move, old_map, [row.offset + ecx], [col.offset + ecx], rows, cols, SHIP.COORDS, 1, 0, 0, 0, [LOCAL(2)]
        pop ecx
        cmp eax, 0
        je condition
        
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
        add eax, 1
        mov [LOCAL(0)], eax

        mov eax, [weapon.col]
        add eax, [col.offset + ecx]
        mov [LOCAL(1)], eax
        push ecx
        CALL weapons.shoot, [LOCAL(0)], [LOCAL(1)], 0
        pop ecx
        jmp after.shoot       
        
        working.on.map:
        CALL red.put_all_in_map, [PARAM(0)]
        end:

    FUNC.END

; red.put_all_in_map(dword *map)
red.put_all_in_map:
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

        mov edx, HASH.ENEMY_RED << 16
        mov dx, [inst + ecx]

        CALL red.put_one_in_map, [PARAM(0)], edx, [LOCAL(1)], [LOCAL(2)]
        
        inc dword [LOCAL(0)]
        jmp .map.all.while
    .map.all.while.end:
    FUNC.END

; red.put_one_in_map(dword *map, dword hash, dword row, dword col)
red.put_one_in_map:
    FUNC.START
    RESERVE(4)  ; coord, offset

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
global enemy_red.collision
enemy_red.collision:
    FUNC.START    

    cmp dword [PARAM(1)], HASH.PLAYER
    je crash_player

    cmp dword [PARAM(1)], HASH.SHOT
    je crash_shoot

    crashed:
    FUNC.END

    crash_player:
    CALL player.take_damage, 5
    jmp crashed

    crash_shoot:
    jmp crashed
    ;  FUNC.START
    ;  inc byte[graphics]
     FUNC.END

;paint()
;move all the red enemies
global enemy_red.paint
enemy_red.paint:
    FUNC.START
    RESERVE(4)
    
    cmp dword [count], 0
    je while.end
   
    mov dword [LOCAL(2)], 0    
    mov dword [LOCAL(3)], 0

    CALL delay, animation.timer, 100   ;the form of the ship change every 100ms
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
        mov dword [graphics + 8], '-'|FG.RED|BG.BLACK
        jmp while.internal

    set.form1:
        mov byte [graphics.style], 1
        mov dword [graphics + 8], '='|FG.RED|BG.BLACK
        jmp while.internal

; enemy_red.take_damage(dword damage, dword instance)
; Takes lives away from an enemy
global enemy_red.take_damage
enemy_red.take_damage:
    FUNC.START
    RESERVE(1)

    mov ecx, [count]
    CALL array.index_of, inst, ecx, [PARAM(1)], 4 
    mov [LOCAL(0)], eax
    shl eax, 2
    mov ecx, [PARAM(0)]

    
    cmp dword [lives + eax], ecx
    jg take_end
    add dword [actual.score], 100
    mov eax, [LOCAL(0)]
    CALL destroy.ship, eax

    take_end:
    sub [lives + eax], ecx
    FUNC.END

;destroy.ship(dword index)
;destroyes the ship that is in the index position
destroy.ship:
    FUNC.START    

    call play_red_enemy_die

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
        mov ebx, [down.count + eax + 4]
        mov dword [down.count + eax], ebx
        mov ebx, [inst + eax + 4]
        mov dword [inst + eax], ebx

        inc dword [LOCAL(0)]
        jmp while

    end.while:

    sub dword [count], 1
    FUNC.END


; enemy_red.reset()
; reset the red enemies
global enemy_red.reset
enemy_red.reset:
    FUNC.START
    mov dword[count], 0
    FUNC.END