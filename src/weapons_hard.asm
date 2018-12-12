%include "video.inc"
%include "stack.inc"
%include "utils.inc"
%include "hash.inc"

%define hard_shots.COORDS 1

section .data

graphics dw 'o'|FG.CYAN|BG.BLACK

rows dw 0
cols dw 0

row.top dw 0
row.bottom dw 0

col.left dw 0
col.right dw 0

hard_shots.count dw 0

hard_shots.next_inst dw 1

section .bss

hard_shots.rows resw ROWS * COLS
hard_shots.cols resw ROWS * COLS
hard_shots.dirs resw ROWS * COLS
hard_shots.insts resw ROWS * COLS
hard_shots.lives resw ROWS * COLS

timer resd 2

section .text

extern video.print
extern delay
extern array.shiftl
extern array.index_of
extern engine.add_collision
extern player.take_damage
extern enemy_blue.take_damage
extern enemy_red.take_damage
extern enemy_yellow.take_damage
extern enemy_boss.take_damage
extern enemy_meteoro.take_damage
extern ai.take_damage

extern debug_info
extern engine.debug

; update(dword *map)
; It is here where all the actions related to this object will be taking place
global hard_weapons.update
hard_weapons.update:
    FUNC.START
    RESERVE(1)  ; i

    CALL delay, timer, 50
    cmp eax, 0
    je .update.move.end


    mov dword [LOCAL(0)], 0
    .update.move:
        mov ecx, [LOCAL(0)]
        
        cmp cx, [hard_shots.count]
        jae .update.move.end

        shl ecx, 1

        xor eax, eax
        mov ax, [hard_shots.dirs + ecx]
        
        cmp eax, 0
        je .move.down

        cmp eax, 1
        je .move.up

        cmp eax, 2
        je .move.left

        cmp eax, 3
        je .move.right

        cmp eax, 4
        je .move.diag_left_up

        cmp eax, 5
        je .move.diag_left_down

        cmp eax, 6
        je .move.diag_right_up

        cmp eax, 7
        je .move.diag_right_down

        jmp .update.move.end

        .move.up:
            dec word [hard_shots.rows + ecx]
            jmp .update.move.cont

        .move.down:
            inc word [hard_shots.rows + ecx]
            jmp .update.move.cont

        .move.left:
            dec word [hard_shots.cols + ecx]
            jmp .update.move.cont

        .move.right:
            inc word [hard_shots.cols + ecx]
            jmp .update.move.cont

        .move.diag_left_down:
            dec word [hard_shots.cols + ecx]
            inc word [hard_shots.rows + ecx]
            jmp .update.move.cont

        .move.diag_left_up:
            dec word [hard_shots.cols + ecx]
            dec word [hard_shots.rows + ecx]
            jmp .update.move.cont

        .move.diag_right_down:
            inc word [hard_shots.cols + ecx]
            inc word [hard_shots.rows + ecx]
            jmp .update.move.cont

        .move.diag_right_up:
            inc word [hard_shots.cols + ecx]
            dec word [hard_shots.rows + ecx]
            jmp .update.move.cont

        .update.move.cont:
            CALL hard_weapons.check_boundaries, [LOCAL(0)]
            cmp eax, 0
            je .update.move
            inc dword [LOCAL(0)]
            jmp .update.move
    .update.move.end:

    CALL hard_weapons.put_all_in_map, [PARAM(0)]    

    FUNC.END

; hard_weapons.put_all_in_map(dword *map)
hard_weapons.put_all_in_map:
    FUNC.START
    RESERVE(3) ; i, row, col

    mov dword [LOCAL(0)], 0
    .map.all.while:
        mov ecx, [LOCAL(0)]
        
        cmp cx, [hard_shots.count]
        je .map.all.while.end

        shl ecx, 1

        xor eax, eax
        mov ax, [hard_shots.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [hard_shots.cols + ecx]
        mov [LOCAL(2)], eax

        mov edx, HASH.HARD_SHOT << 16
        mov dx, [hard_shots.insts + ecx]

        CALL hard_weapons.put_one_in_map, [PARAM(0)], edx, [LOCAL(1)], [LOCAL(2)]
        
        inc dword [LOCAL(0)]
        jmp .map.all.while
    .map.all.while.end:
    FUNC.END

; hard_weapons.put_one_in_map(dword *map, dword hash, dword row, dword col)
hard_weapons.put_one_in_map:
    FUNC.START
    RESERVE(2)  ; coord, offset

    mov dword [LOCAL(0)], 0
    .map.one.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, hard_shots.COORDS
        je .map.one.while.end

        shl ecx, 1
        
        xor eax, eax
        mov ax, [rows + ecx]
        add [PARAM(2)], eax
        
        xor eax, eax
        mov ax, [cols + ecx]
        add [PARAM(3)], eax

        OFFSET [PARAM(2)], [PARAM(3)]

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

; paint()
; Puts the object's graphics in the screen
global hard_weapons.paint
hard_weapons.paint:
    FUNC.START
    RESERVE(3)  ; i, row, col

    mov dword [LOCAL(0)], 0
    .paint.while:
        mov ecx, [LOCAL(0)]
        
        cmp cx, [hard_shots.count]
        je .paint.while.end

        shl ecx, 1

        xor eax, eax
        mov ax, [hard_shots.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [hard_shots.cols + ecx]
        mov [LOCAL(2)], eax

        CALL hard_weapons.paint_shot, [LOCAL(1)], [LOCAL(2)]
        
        inc dword [LOCAL(0)]
        jmp .paint.while
    .paint.while.end:
    
    FUNC.END

; hard_weapons.paint_shot(dword row, dword col)
; Paints one shot at row, col
hard_weapons.paint_shot:
    FUNC.START
    RESERVE(2)  ; coord, graphics

    mov dword [LOCAL(0)], 0
    .pshot.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, hard_shots.COORDS
        je .pshot.while.end

        shl ecx, 1
        
        xor eax, eax
        mov ax, [rows + ecx]
        add [PARAM(0)], eax
        
        xor eax, eax
        mov ax, [cols + ecx]
        add [PARAM(1)], eax

        xor eax, eax
        mov ax, [graphics + ecx]
        mov [LOCAL(1)], eax

        CALL video.print, [LOCAL(1)], [PARAM(0)], [PARAM(1)]

        inc dword [LOCAL(0)]
        jmp .pshot.while
    .pshot.while.end:

    FUNC.END

; collision(dword inst, dword hash_hard, dword inst_hard)
; It is here where collisions will be handled
global hard_weapons.collision
hard_weapons.collision:
    FUNC.START
    RESERVE(3)
    xor eax, eax
    mov ax, [hard_shots.count]
    CALL array.index_of, hard_shots.insts, eax, [PARAM(0)], 2
    mov [LOCAL(0)], eax

    cmp dword [PARAM(1)], HASH.PLAYER
    je .kill.player

    cmp dword [PARAM(1)], HASH.AI
    je .kill.ai

    cmp dword [PARAM(1)], HASH.ENEMY_BLUE
    je .kill.enemy_blue

    cmp dword [PARAM(1)], HASH.ENEMY_RED
    je .kill.enemy_red

    cmp dword [PARAM(1)], HASH.ENEMY_YELLOW
    je .kill.enemy_yellow

    cmp dword [PARAM(1)], HASH.ENEMY_BOSS
    je .kill.enemy_boss

    cmp dword [PARAM(1)], HASH.ENEMY_METEORO
    je .kill.enemy_meteoro

    jmp .collision.end

    .kill.player:
        CALL player.take_damage, 1
        mov [LOCAL(1)], eax

        mov eax, [LOCAL(0)]
        dec word [hard_shots.lives + eax]

        cmp word [hard_shots.lives + eax], 0
        je .collision.check_lives

        cmp dword [LOCAL(1)], 0
        ja .kill.player

        jmp .collision.check_lives

    .kill.ai:
        CALL ai.take_damage, 1
        mov [LOCAL(1)], eax

        mov eax, [LOCAL(0)]
        dec word [hard_shots.lives + eax]

        cmp word [hard_shots.lives + eax], 0
        je .collision.check_lives

        cmp dword [LOCAL(1)], 0
        ja .kill.player

        jmp .collision.check_lives

    .kill.enemy_blue:
        CALL enemy_blue.take_damage, 1, [PARAM(2)]
        mov [LOCAL(1)], eax

        mov eax, [LOCAL(0)]
        dec word [hard_shots.lives + eax]

        cmp word [hard_shots.lives + eax], 0
        je .collision.check_lives

        cmp dword [LOCAL(1)], 0
        ja .kill.enemy_blue

        jmp .collision.check_lives

    .kill.enemy_red:
        CALL enemy_red.take_damage, 1, [PARAM(2)]
        mov [LOCAL(1)], eax
        
        mov eax, [LOCAL(0)]
        dec word [hard_shots.lives + eax]

        cmp word [hard_shots.lives + eax], 0
        je .collision.check_lives

        cmp dword [LOCAL(1)], 0
        ja .kill.enemy_red

        jmp .collision.check_lives

    .kill.enemy_yellow:
        CALL enemy_yellow.take_damage, 1, [PARAM(2)]
        mov [LOCAL(1)], eax

        mov eax, [LOCAL(0)]
        dec word [hard_shots.lives + eax]

        cmp word [hard_shots.lives + eax], 0
        je .collision.check_lives

        cmp dword [LOCAL(1)], 0
        ja .kill.enemy_yellow

        jmp .collision.check_lives

        .kill.enemy_meteoro:
        CALL enemy_meteoro.take_damage, 1, [PARAM(2)]
        mov [LOCAL(1)], eax

        mov eax, [LOCAL(0)]
        dec word [hard_shots.lives + eax]

        cmp word [hard_shots.lives + eax], 0
        je .collision.check_lives

        cmp dword [LOCAL(1)], 0
        ja .kill.enemy_meteoro

        jmp .collision.check_lives

        .kill.enemy_boss:
        CALL enemy_boss.take_damage, 1, [PARAM(2)]
        mov [LOCAL(1)], eax

        mov eax, [LOCAL(0)]
        dec word [hard_shots.lives + eax]

        cmp word [hard_shots.lives + eax], 0
        je .collision.check_lives

        cmp dword [LOCAL(1)], 0
        ja .kill.enemy_boss

        jmp .collision.check_lives

    .collision.check_lives:
        mov eax, [LOCAL(0)]
        cmp word [hard_shots.lives + eax], 0
        jne .collision.end

        CALL hard_weapons.remove, [LOCAL(0)]
    .collision.end:
    FUNC.END

; hard_weapons.shoot(dword row, dword col, dword dir)
; creates a shot in position row, column that will move in direction dir
; (dir = 0) => shot moves down 
; (dir = 1) => shot moves up
global hard_weapons.shoot
hard_weapons.shoot:
    FUNC.START

    CALL hard_weapons.find_shot, [PARAM(0)], [PARAM(1)]

    mov ecx, eax

    cmp cx, [hard_shots.count]
    jne .shoot.end

    shl ecx, 1

    mov eax, [PARAM(0)]
    mov [hard_shots.rows + ecx], ax
    
    mov eax, [PARAM(1)]
    mov [hard_shots.cols + ecx], ax

    mov eax, [PARAM(2)]
    mov [hard_shots.dirs + ecx], ax

    mov ax, [hard_shots.next_inst]
    mov [hard_shots.insts + ecx], ax

    mov word [hard_shots.lives + ecx], 10

    inc word [hard_shots.count]
    inc word [hard_shots.next_inst]

    .shoot.end:
        FUNC.END

; find_shot(dword row, dword col)
; returns index of a shot at row, col
hard_weapons.find_shot:
    FUNC.START
    RESERVE(1)  ; i

    mov dword [LOCAL(0)], 0
    .find.while:
        mov ecx, [LOCAL(0)]
        
        cmp cx, [hard_shots.count]
        je .find.while.end

        shl ecx, 1

        mov eax, [PARAM(0)]
        cmp [hard_shots.rows + ecx], eax
        jne .find.while.cont

        mov eax, [PARAM(1)]
        cmp [hard_shots.cols + ecx], eax
        jne .find.while.cont

        jmp .find.while.end
        
        .find.while.cont:
            inc dword [LOCAL(0)]
            jmp .find.while
    .find.while.end:

    mov eax, [LOCAL(0)]

    FUNC.END

; hard_weapons.check_boundaries(dword pos)
; Checks if the shot at the given pos is outside the boundaries of the map,
; if so, removes it
hard_weapons.check_boundaries:
    FUNC.START
    
    mov ecx, [PARAM(0)]
    shl ecx, 1

    cmp word [hard_shots.rows + ecx], ROWS
    jae .check.rm

    cmp word [hard_shots.cols + ecx], COLS
    jae .check.rm

    mov eax, 1
    jmp .check.end
    
    .check.rm:
        CALL hard_weapons.remove, [PARAM(0)]
        mov eax, 0

    .check.end:
        FUNC.END

; hard_weapons.remove(dword pos)
; Removes shot stored at the given pos in the list
hard_weapons.remove:
    FUNC.START
    RESERVE(1)

    xor eax, eax
    mov ax, [hard_shots.count]
    mov [LOCAL(0)], eax

    CALL array.shiftl, hard_shots.rows, [LOCAL(0)], [PARAM(0)]
    CALL array.shiftl, hard_shots.cols, [LOCAL(0)], [PARAM(0)]
    CALL array.shiftl, hard_shots.dirs, [LOCAL(0)], [PARAM(0)]
    CALL array.shiftl, hard_shots.insts, [LOCAL(0)], [PARAM(0)]
    CALL array.shiftl, hard_shots.lives, [LOCAL(0)], [PARAM(0)]

    dec word [hard_shots.count]
    FUNC.END

; hard_weapons.reset())
; reset the hard_weapons
global hard_weapons.reset
hard_weapons.reset:
    FUNC.START
    mov word [hard_shots.count], 0
    FUNC.END
