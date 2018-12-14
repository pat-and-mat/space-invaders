%include "video.inc"
%include "stack.inc"
%include "utils.inc"
%include "hash.inc"

%define multi_shots.COORDS 1

section .data

graphics dw 'o'|FG.GREEN|BG.BLACK

rows dw 0
cols dw 0

row.top dw 0
row.bottom dw 0

col.left dw 0
col.right dw 0

multi_shots.count dw 0

multi_shots.next_inst dw 1

section .bss

multi_shots.rows resw ROWS * COLS
multi_shots.cols resw ROWS * COLS
multi_shots.dirs resw ROWS * COLS
multi_shots.insts resw ROWS * COLS
multi_shots.lives resw ROWS * COLS

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
extern ai.take_damage
extern enemy_boss.take_damage
extern enemy_meteoro.take_damage

extern debug_info
extern engine.debug

; update(dword *map)
; It is here where all the actions related to this object will be taking place
global multi_weapons.update
multi_weapons.update:
    FUNC.START
    RESERVE(1)  ; i

    CALL delay, timer, 50
    cmp eax, 0
    je .update.move.end


    mov dword [LOCAL(0)], 0
    .update.move:
        mov ecx, [LOCAL(0)]
        
        cmp cx, [multi_shots.count]
        jae .update.move.end

        shl ecx, 1

        xor eax, eax
        mov ax, [multi_shots.dirs + ecx]
        
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
            dec word [multi_shots.rows + ecx]
            jmp .update.move.cont

        .move.down:
            inc word [multi_shots.rows + ecx]
            jmp .update.move.cont

        .move.left:
            dec word [multi_shots.cols + ecx]
            jmp .update.move.cont

        .move.right:
            inc word [multi_shots.cols + ecx]
            jmp .update.move.cont

        .move.diag_left_down:
            dec word [multi_shots.cols + ecx]
            inc word [multi_shots.rows + ecx]
            jmp .update.move.cont

        .move.diag_left_up:
            dec word [multi_shots.cols + ecx]
            dec word [multi_shots.rows + ecx]
            jmp .update.move.cont

        .move.diag_right_down:
            inc word [multi_shots.cols + ecx]
            inc word [multi_shots.rows + ecx]
            jmp .update.move.cont

        .move.diag_right_up:
            inc word [multi_shots.cols + ecx]
            dec word [multi_shots.rows + ecx]
            jmp .update.move.cont

        .update.move.cont:
            CALL multi_weapons.check_boundaries, [LOCAL(0)]
            cmp eax, 0
            je .update.move
            inc dword [LOCAL(0)]
            jmp .update.move
    .update.move.end:

    CALL multi_weapons.put_all_in_map, [PARAM(0)]    

    FUNC.END

; multi_weapons.put_all_in_map(dword *map)
multi_weapons.put_all_in_map:
    FUNC.START
    RESERVE(3) ; i, row, col

    mov dword [LOCAL(0)], 0
    .map.all.while:
        mov ecx, [LOCAL(0)]
        
        cmp cx, [multi_shots.count]
        je .map.all.while.end

        shl ecx, 1

        xor eax, eax
        mov ax, [multi_shots.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [multi_shots.cols + ecx]
        mov [LOCAL(2)], eax

        mov edx, HASH.MULTI_SHOT << 16
        mov dx, [multi_shots.insts + ecx]

        CALL multi_weapons.put_one_in_map, [PARAM(0)], edx, [LOCAL(1)], [LOCAL(2)]
        
        inc dword [LOCAL(0)]
        jmp .map.all.while
    .map.all.while.end:
    FUNC.END

; multi_weapons.put_one_in_map(dword *map, dword hash, dword row, dword col)
multi_weapons.put_one_in_map:
    FUNC.START
    RESERVE(2)  ; coord, offset

    mov dword [LOCAL(0)], 0
    .map.one.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, multi_shots.COORDS
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
global multi_weapons.paint
multi_weapons.paint:
    FUNC.START
    RESERVE(3)  ; i, row, col

    mov dword [LOCAL(0)], 0
    .paint.while:
        mov ecx, [LOCAL(0)]
        
        cmp cx, [multi_shots.count]
        je .paint.while.end

        shl ecx, 1

        xor eax, eax
        mov ax, [multi_shots.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [multi_shots.cols + ecx]
        mov [LOCAL(2)], eax

        CALL multi_weapons.paint_shot, [LOCAL(1)], [LOCAL(2)]
        
        inc dword [LOCAL(0)]
        jmp .paint.while
    .paint.while.end:
    
    FUNC.END

; multi_weapons.paint_shot(dword row, dword col)
; Paints one shot at row, col
multi_weapons.paint_shot:
    FUNC.START
    RESERVE(2)  ; coord, graphics

    mov dword [LOCAL(0)], 0
    .pshot.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, multi_shots.COORDS
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

; collision(dword inst, dword hash_multi, dword inst_multi)
; It is here where collisions will be handled
global multi_weapons.collision
multi_weapons.collision:
    FUNC.START
    RESERVE(3)
    xor eax, eax
    mov ax, [multi_shots.count]
    CALL array.index_of, multi_shots.insts, eax, [PARAM(0)], 2
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
        shl eax, 1
        
        dec word [multi_shots.lives + eax]

        cmp word [multi_shots.lives + eax], 0
        je .collision.check_lives

        cmp dword [LOCAL(1)], 0
        ja .kill.player

        jmp .collision.check_lives

    .kill.ai:
        CALL ai.take_damage, 1
        mov [LOCAL(1)], eax

        mov eax, [LOCAL(0)]
        shl eax, 1
        
        dec word [multi_shots.lives + eax]

        cmp word [multi_shots.lives + eax], 0
        je .collision.check_lives

        cmp dword [LOCAL(1)], 0
        ja .kill.ai

        jmp .collision.check_lives

    .kill.enemy_blue:
        CALL enemy_blue.take_damage, 1, [PARAM(2)]
        mov [LOCAL(1)], eax

        mov eax, [LOCAL(0)]
        shl eax, 1
        
        dec word [multi_shots.lives + eax]

        cmp word [multi_shots.lives + eax], 0
        je .collision.check_lives

        cmp dword [LOCAL(1)], 0
        ja .kill.enemy_blue

        jmp .collision.check_lives

    .kill.enemy_red:
        CALL enemy_red.take_damage, 1, [PARAM(2)]
        mov [LOCAL(1)], eax
        
        mov eax, [LOCAL(0)]
        shl eax, 1
        
        dec word [multi_shots.lives + eax]

        cmp word [multi_shots.lives + eax], 0
        je .collision.check_lives

        cmp dword [LOCAL(1)], 0
        ja .kill.enemy_red

        jmp .collision.check_lives

    .kill.enemy_yellow:
        CALL enemy_yellow.take_damage, 1, [PARAM(2)]
        mov [LOCAL(1)], eax

        mov eax, [LOCAL(0)]
        shl eax, 1
        
        dec word [multi_shots.lives + eax]

        cmp word [multi_shots.lives + eax], 0
        je .collision.check_lives

        cmp dword [LOCAL(1)], 0
        ja .kill.enemy_yellow

        jmp .collision.check_lives

        .kill.enemy_meteoro:
        CALL enemy_meteoro.take_damage, 1, [PARAM(2)]
        mov [LOCAL(1)], eax

        mov eax, [LOCAL(0)]
        shl eax, 1
        
        dec word [multi_shots.lives + eax]

        cmp word [multi_shots.lives + eax], 0
        je .collision.check_lives

        cmp dword [LOCAL(1)], 0
        ja .kill.enemy_meteoro

        jmp .collision.check_lives

        .kill.enemy_boss:
        CALL enemy_boss.take_damage, 1, [PARAM(2)]
        mov [LOCAL(1)], eax

        mov eax, [LOCAL(0)]
        shl eax, 1
        
        dec word [multi_shots.lives + eax]

        cmp word [multi_shots.lives + eax], 0
        je .collision.check_lives

        cmp dword [LOCAL(1)], 0
        ja .kill.enemy_boss

        jmp .collision.check_lives

    .collision.check_lives:
        mov eax, [LOCAL(0)]
        shl eax, 1
        
        cmp word [multi_shots.lives + eax], 0
        jne .collision.end

        CALL multi_weapons.remove, [LOCAL(0)]
    .collision.end:
    FUNC.END

; multi_weapons.shoot(dword row, dword col, dword dir)
; creates a shot in position row, column that will move in direction dir
; (dir = 0) => shot moves down 
; (dir = 1) => shot moves up
global multi_weapons.shoot
multi_weapons.shoot:
    FUNC.START

    cmp dword [PARAM(0)], ROWS
    jae .shoot.end

    cmp dword [PARAM(1)], COLS
    jae .shoot.end

    CALL multi_weapons.find_shot, [PARAM(0)], [PARAM(1)]

    mov ecx, eax

    cmp cx, [multi_shots.count]
    jne .shoot.end

    shl ecx, 1

    mov eax, [PARAM(0)]
    mov [multi_shots.rows + ecx], ax
    
    mov eax, [PARAM(1)]
    mov [multi_shots.cols + ecx], ax

    mov eax, [PARAM(2)]
    mov [multi_shots.dirs + ecx], ax

    mov ax, [multi_shots.next_inst]
    mov [multi_shots.insts + ecx], ax

    mov word [multi_shots.lives + ecx], 2

    inc word [multi_shots.count]
    inc word [multi_shots.next_inst]

    .shoot.end:
        FUNC.END

; find_shot(dword row, dword col)
; returns index of a shot at row, col
multi_weapons.find_shot:
    FUNC.START
    RESERVE(1)  ; i

    mov dword [LOCAL(0)], 0
    .find.while:
        mov ecx, [LOCAL(0)]
        
        cmp cx, [multi_shots.count]
        je .find.while.end

        shl ecx, 1

        mov eax, [PARAM(0)]
        cmp [multi_shots.rows + ecx], eax
        jne .find.while.cont

        mov eax, [PARAM(1)]
        cmp [multi_shots.cols + ecx], eax
        jne .find.while.cont

        jmp .find.while.end
        
        .find.while.cont:
            inc dword [LOCAL(0)]
            jmp .find.while
    .find.while.end:

    mov eax, [LOCAL(0)]

    FUNC.END

; multi_weapons.check_boundaries(dword pos)
; Checks if the shot at the given pos is outside the boundaries of the map,
; if so, removes it
multi_weapons.check_boundaries:
    FUNC.START
    
    mov ecx, [PARAM(0)]
    shl ecx, 1

    cmp word [multi_shots.rows + ecx], ROWS
    jae .check.rm

    cmp word [multi_shots.cols + ecx], COLS
    jae .check.rm

    mov eax, 1
    jmp .check.end
    
    .check.rm:
        CALL multi_weapons.remove, [PARAM(0)]
        mov eax, 0

    .check.end:
        FUNC.END

; multi_weapons.remove(dword pos)
; Removes shot stored at the given pos in the list
multi_weapons.remove:
    FUNC.START
    RESERVE(1)

    xor eax, eax
    mov ax, [multi_shots.count]
    mov [LOCAL(0)], eax

    CALL array.shiftl, multi_shots.rows, [LOCAL(0)], [PARAM(0)]
    CALL array.shiftl, multi_shots.cols, [LOCAL(0)], [PARAM(0)]
    CALL array.shiftl, multi_shots.dirs, [LOCAL(0)], [PARAM(0)]
    CALL array.shiftl, multi_shots.insts, [LOCAL(0)], [PARAM(0)]
    CALL array.shiftl, multi_shots.lives, [LOCAL(0)], [PARAM(0)]

    dec word [multi_shots.count]
    FUNC.END

; multi_weapons.reset())
; reset the multi_weapons
global multi_weapons.reset
multi_weapons.reset:
    FUNC.START
    mov word [multi_shots.count], 0
    FUNC.END
