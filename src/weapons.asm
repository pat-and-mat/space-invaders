%include "video.inc"
%include "stack.inc"
%include "utils.inc"
%include "hash.inc"

%define SHOTS.COORDS 1

section .data

graphics dw 'o'|FG.RED|BG.BLACK

rows dw 0
cols dw 0

row.top dw 0
row.bottom dw 0

col.left dw 0
col.right dw 0

shots.count dw 0

shots.next_inst dw 1

section .bss

shots.rows resw ROWS * COLS
shots.cols resw ROWS * COLS
shots.dirs resw ROWS * COLS
shots.insts resw ROWS * COLS

timer resd 1

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


; update(dword *map)
; It is here where all the actions related to this object will be taking place
global weapons.update
weapons.update:
    FUNC.START
    RESERVE(1)  ; i

    CALL delay, timer, 50
    cmp eax, 0
    je .update.move.end


    mov dword [LOCAL(0)], 0
    .update.move:
        mov ecx, [LOCAL(0)]
        
        cmp cx, [shots.count]
        jae .update.move.end

        shl ecx, 1

        xor eax, eax
        mov ax, [shots.dirs + ecx]
        
        cmp eax, 0
        je .move.down

        cmp eax, 1
        je .move.up

        jmp .update.move.end

        .move.up:
            dec word [shots.rows + ecx]
            jmp .update.move.cont

        .move.down:
            inc word [shots.rows + ecx]
            jmp .update.move.cont

        .update.move.cont:
            CALL weapons.check_boundaries, [LOCAL(0)]
            cmp eax, 0
            je .update.move
            inc dword [LOCAL(0)]
            jmp .update.move
    .update.move.end:

    CALL weapons.put_all_in_map, [PARAM(0)]    

    FUNC.END

; weapons.put_all_in_map(dword *map)
weapons.put_all_in_map:
    FUNC.START
    RESERVE(3) ; i, row, col

    mov dword [LOCAL(0)], 0
    .map.all.while:
        mov ecx, [LOCAL(0)]
        
        cmp cx, [shots.count]
        je .map.all.while.end

        shl ecx, 1

        xor eax, eax
        mov ax, [shots.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [shots.cols + ecx]
        mov [LOCAL(2)], eax

        mov edx, HASH.SHOT << 16
        mov dx, [shots.insts + ecx]

        CALL weapons.put_one_in_map, [PARAM(0)], edx, [LOCAL(1)], [LOCAL(2)]
        
        inc dword [LOCAL(0)]
        jmp .map.all.while
    .map.all.while.end:
    FUNC.END

; weapons.put_one_in_map(dword *map, dword hash, dword row, dword col)
weapons.put_one_in_map:
    FUNC.START
    RESERVE(2)  ; coord, offset

    mov dword [LOCAL(0)], 0
    .map.one.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, SHOTS.COORDS
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
global weapons.paint
weapons.paint:
    FUNC.START
    RESERVE(3)  ; i, row, col

    mov dword [LOCAL(0)], 0
    .paint.while:
        mov ecx, [LOCAL(0)]
        
        cmp cx, [shots.count]
        je .paint.while.end

        shl ecx, 1

        xor eax, eax
        mov ax, [shots.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [shots.cols + ecx]
        mov [LOCAL(2)], eax

        CALL weapons.paint_shot, [LOCAL(1)], [LOCAL(2)]
        
        inc dword [LOCAL(0)]
        jmp .paint.while
    .paint.while.end:
    
    FUNC.END

; weapons.paint_shot(dword row, dword col)
; Paints one shot at row, col
weapons.paint_shot:
    FUNC.START
    RESERVE(2)  ; coord, graphics

    mov dword [LOCAL(0)], 0
    .pshot.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, SHOTS.COORDS
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

; collision(dword inst, dword hash_other, dword inst_other)
; It is here where collisions will be handled
global weapons.collision
weapons.collision:
    FUNC.START
    xor eax, eax
    mov ax, [shots.count]
    CALL array.index_of, shots.insts, eax, [PARAM(0)], 2
    CALL weapons.remove, eax

    cmp dword [PARAM(1)], HASH.PLAYER
    je .kill.player

    cmp dword [PARAM(1)], HASH.ENEMY_BLUE
    je .kill.enemy_blue

    cmp dword [PARAM(1)], HASH.ENEMY_RED
    je .kill.enemy_red

    cmp dword [PARAM(1)], HASH.ENEMY_YELLOW
    je .kill.enemy_yellow

    cmp dword [PARAM(1)], HASH.ENEMY_METEORO
    je .kill.meteoro

    cmp dword [PARAM(1)], HASH.ENEMY_BOSS
    je .kill.boss

    
    jmp .collision.end

    .kill.player:
        CALL player.take_damage, 5
        jmp .collision.end

    .kill.meteoro:
        CALL enemy_meteoro.take_damage, 1, [PARAM(2)]
        jmp .collision.end

    .kill.boss:
        CALL enemy_boss.take_damage, 1, [PARAM(2)]
        jmp .collision.end

    .kill.enemy_blue:
        CALL enemy_blue.take_damage, 1, [PARAM(2)]
        jmp .collision.end

    .kill.enemy_red:
        CALL enemy_red.take_damage, 1, [PARAM(2)]
        jmp .collision.end

    .kill.enemy_yellow:
        CALL enemy_yellow.take_damage, 1, [PARAM(2)]
        jmp .collision.end
    
    .collision.end:
    FUNC.END

; weapons.shoot(dword row, dword col, dword dir)
; creates a shot in position row, column that will move in direction dir
; (dir = 0) => shot moves down 
; (dir = 1) => shot moves up
global weapons.shoot
weapons.shoot:
    FUNC.START

    CALL weapons.find_shot, [PARAM(0)], [PARAM(1)]

    mov ecx, eax

    cmp cx, [shots.count]
    jne .shoot.end

    shl ecx, 1

    mov eax, [PARAM(0)]
    mov [shots.rows + ecx], ax
    
    mov eax, [PARAM(1)]
    mov [shots.cols + ecx], ax

    mov eax, [PARAM(2)]
    mov [shots.dirs + ecx], ax

    mov ax, [shots.next_inst]
    mov [shots.insts + ecx], ax

    inc word [shots.count]
    inc word [shots.next_inst]

    .shoot.end:
        FUNC.END

; find_shot(dword row, dword col)
; returns index of a shot at row, col
weapons.find_shot:
    FUNC.START
    RESERVE(1)  ; i

    mov dword [LOCAL(0)], 0
    .find.while:
        mov ecx, [LOCAL(0)]
        
        cmp cx, [shots.count]
        je .find.while.end

        shl ecx, 1

        mov eax, [PARAM(0)]
        cmp [shots.rows + ecx], eax
        jne .find.while.cont

        mov eax, [PARAM(1)]
        cmp [shots.cols + ecx], eax
        jne .find.while.cont

        jmp .find.while.end
        
        .find.while.cont:
            inc dword [LOCAL(0)]
            jmp .find.while
    .find.while.end:

    mov eax, [LOCAL(0)]

    FUNC.END

; weapons.check_boundaries(dword pos)
; Checks if the shot at the given pos is outside the boundaries of the map,
; if so, removes it
weapons.check_boundaries:
    FUNC.START
    
    mov ecx, [PARAM(0)]
    shl ecx, 1

    cmp word [shots.rows + ecx], ROWS
    jae .check.rm

    mov eax, 1
    jmp .check.end
    
    .check.rm:
        CALL weapons.remove, [PARAM(0)]
        mov eax, 0

    .check.end:
        FUNC.END

; weapons.remove(dword pos)
; Removes shot stored at the given pos in the list
weapons.remove:
    FUNC.START
    RESERVE(1)

    xor eax, eax
    mov ax, [shots.count]
    mov [LOCAL(0)], eax

    CALL array.shiftl, shots.rows, [LOCAL(0)], [PARAM(0)]
    CALL array.shiftl, shots.cols, [LOCAL(0)], [PARAM(0)]
    CALL array.shiftl, shots.dirs, [LOCAL(0)], [PARAM(0)]
    CALL array.shiftl, shots.insts, [LOCAL(0)], [PARAM(0)]

    dec word [shots.count]
    FUNC.END

; weapons.reset())
; reset the weapons
global weapons.reset
weapons.reset:
    FUNC.START
    mov word [shots.count], 0
    FUNC.END
