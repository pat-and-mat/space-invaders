%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"
%include "sound.inc"
%include "utils.inc"
%include "hash.inc"

extern video.print
extern weapons.shoot
extern engine.add_collision
extern input
extern beep.on
extern beep.set
extern beep.off
extern delay
extern play_shoot
extern play_player_die
extern menu.lose
extern sound_player_die.update
extern sound.timer
extern enemy_blue.take_damage
extern enemy_red.take_damage
extern enemy_yellow.take_damage


extern debug_info
extern engine.debug
extern other_weapons.shoot

%define SHIP.COORDS 5

%macro SHIP.ROW 1
    xor eax, eax
    ; mov ax, [row.offset]
    ; add ax, %1
%endmacro

%macro SHIP.COL 1
    xor eax, eax
    mov ax, [col.offset]
    add ax, %1
%endmacro

; Data section is meant to hold constant values, do not modify
section .data

graphics dd '/'|FG.GRAY|BG.BLACK,\
            '-'|FG.GRAY|BG.BLACK,\
            '^'|FG.GRAY|BG.BLACK,\
            '-'|FG.GRAY|BG.BLACK,\
            '\'|FG.GRAY|BG.BLACK,\

shield_graphics dd  ' '|FG.YELLOW|BG.BLACK,'-'|FG.YELLOW|BG.BLACK,' '|FG.YELLOW|BG.BLACK,'-'|FG.YELLOW|BG.BLACK,' '|FG.YELLOW|BG.BLACK,'-'|FG.YELLOW|BG.BLACK,' '|FG.YELLOW|BG.BLACK,\
                    '|'|FG.YELLOW|BG.BLACK,' '|FG.YELLOW|BG.BLACK,' '|FG.YELLOW|BG.BLACK,' '|FG.YELLOW|BG.BLACK,' '|FG.YELLOW|BG.BLACK,' '|FG.YELLOW|BG.BLACK,'|'|FG.YELLOW|BG.BLACK,\
                    ' '|FG.YELLOW|BG.BLACK,'_'|FG.YELLOW|BG.BLACK,' '|FG.YELLOW|BG.BLACK,'_'|FG.YELLOW|BG.BLACK,' '|FG.YELLOW|BG.BLACK,'_'|FG.YELLOW|BG.BLACK,' '|FG.YELLOW|BG.BLACK,\
            
rows dd 0, 0, 0, 0, 0
cols dd 0, 1, 2, 3, 4

shield_rows dd 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2
shield_cols dd 0, 1, 2, 3, 4, 5, 6, 0, 1, 2, 3, 4, 5, 6, 0, 1, 2, 3, 4, 5, 6

shield_graphics.style db 0

col.left dd 0
col.right dd 3

weapon.row dd 0
weapon.col dd 2

graphics.style db 0

global shield_life
shield_life dd 0

section .bss

global player.lives
player.lives resw 1

row.offset resd 1
col.offset resd 1

animation.timer resd 2
shield_animation.timer resd 2
lose.timer resd 2

section .text

; init(word player.lives, dword r.offset, dword c.offset)
; Initialize player
global player.init
player.init:
    FUNC.START
    ;filling local vars of player
    mov bx, [PARAM(0)]
    mov [player.lives], bx

    mov dword [shield_life], 10
    
    mov ebx, [PARAM(1)]
    mov [row.offset], ebx
    
    mov ebx, [PARAM(2)]
    mov [col.offset], ebx

    FUNC.END

; update(dword *map)
; It is here where all the actions related to this object will be taking place
global player.update
player.update:
    FUNC.START
    RESERVE(2);shoot.row, shoot.col

    continue:
    
    ;down button
    cmp byte [input], KEY.UP
    je up

    ;down button
    cmp byte [input], KEY.DOWN
    je down  

    ;left button
    cmp byte [input], KEY.LEFT
    je left  

    ;right button
    cmp byte [input], KEY.RIGHT
    je right

    ; space button
    cmp byte [input], KEY.SPACE
    je space

    jmp update.end

    up:
        cmp dword [row.offset], 1
        je update.end
        sub dword [row.offset], 1
        jmp update.end

    down:
        cmp dword [row.offset], 24
        je update.end
        add dword [row.offset], 1
        jmp update.end

    left:
        cmp dword [col.offset], 0
        je update.end
        sub dword [col.offset], 1
        jmp update.end

    right:
        cmp dword [col.offset], 75
        je update.end    
        add dword [col.offset], 1
        jmp update.end

    space:        
        ;animating the shoot
        mov dword [graphics + 8], 173|FG.GRAY|BG.BLACK
        mov dword [animation.timer], 0
        ;shoot sound
        call play_shoot

        ;calculate the position of the shot
        mov eax, [weapon.row]
        add eax, [row.offset]
        sub eax, 1
        mov [LOCAL(0)], eax

        mov eax, [weapon.col]
        add eax, [col.offset]
        mov [LOCAL(1)], eax

        CALL weapons.shoot, [LOCAL(0)], [LOCAL(1)], 1
        
        jmp update.end 

    update.end:
        CALL player.put_in_map, [PARAM(0)]   
    
    FUNC.END

; player.put_in_map(dword *map)
player.put_in_map:
    FUNC.START
    RESERVE(4) ; i, row, col, offset

    mov dword [LOCAL(0)], 0
    .map.while:
        cmp dword [LOCAL(0)], SHIP.COORDS
        je .map.while.end

        mov ecx, [LOCAL(0)]
        shl ecx, 2

        mov eax, [row.offset]
        add eax, [rows + ecx]
        mov [LOCAL(1)], eax

        mov eax, [col.offset]
        add eax, [cols + ecx]
        mov [LOCAL(2)], eax

        OFFSET [LOCAL(1)], [LOCAL(2)]

        mov [LOCAL(3)], eax
        shl eax, 2
        add eax, [PARAM(0)]
        
        cmp dword [eax], 0
        je .map.while.cont

        ; Collision
        CALL engine.add_collision, HASH.PLAYER << 16, [eax]

        .map.while.cont:
            mov eax, [LOCAL(3)]
            shl eax, 2
            add eax, [PARAM(0)]

            mov dword [eax], HASH.PLAYER << 16
            inc dword [LOCAL(0)]
            jmp .map.while
    .map.while.end:
    FUNC.END

; collision(dword hash_other, dword inst_other)
; It is here where collisions will be handled
global player.collision
player.collision:
    FUNC.START
    cmp dword [PARAM(0)], HASH.ENEMY_BLUE
    je crash_blue
    cmp dword [PARAM(0)], HASH.ENEMY_RED
    je crash_red
    cmp dword [PARAM(0)], HASH.ENEMY_YELLOW
    je crash_yellow
    
    jmp crashed

    crash_blue:
    CALL enemy_blue.take_damage, 1, [PARAM(1)]
    jmp crashed

    crash_red:
    CALL enemy_red.take_damage, 1, [PARAM(1)]
    jmp crashed

    crash_yellow:
    CALL enemy_yellow.take_damage, 1, [PARAM(1)]
    jmp crashed
    
    crashed:
    FUNC.END

; paint()
; Puts the object's graphics in the screen
global player.paint
player.paint:
    FUNC.START
    RESERVE(4)
    cmp dword [shield_life], 0
    jle cont
    mov eax, [row.offset]
    dec eax
    mov [LOCAL(2)], eax
    mov eax, [col.offset]
    dec eax
    mov [LOCAL(3)], eax
    CALL paint_shield, [LOCAL(2)], [LOCAL(3)]    

    CALL delay, animation.timer, 250   ;the form of the ship change every 300ms
    cmp eax, 0
    je cont
    jmp set.form1

    cont:

    mov ecx, 0    
    while:
        cmp ecx, SHIP.COORDS * 4
        jnl while.end
        
        mov eax, [row.offset]
        add eax, [rows + ecx]
        mov [LOCAL(0)], eax

        mov eax, [col.offset]
        add eax, [cols + ecx]
        mov [LOCAL(1)], eax

        push ecx
        CALL video.print, [graphics + ecx], [LOCAL(0)], [LOCAL(1)]
        pop ecx

        add ecx, 4
        jmp while
        while.end:
        FUNC.END

    set.form1:
        mov byte [graphics.style], 1
        mov dword [graphics + 8], '^'|FG.GRAY|BG.BLACK
        jmp cont

; player.take_damage(dword damage)
; Takes player.lives away from player
; returns 1 if player remains alive after damage, 0 otherwise
global player.take_damage
player.take_damage:
    FUNC.START
    mov dword [PARAM(0)], 0 ; debug

    mov eax, [PARAM(0)]

    cmp eax, [shield_life]
    jge destroy_shield
    sub [shield_life], eax
    jmp end

    destroy_shield:
    mov dword [shield_life], 0
    sub eax, [shield_life]
    
    cmp [player.lives], ax
    jng .destroyed
    sub [player.lives], ax
    jmp end

    .destroyed:
        mov word [player.lives], 0

    end:
        xor eax, eax
        mov ax, [player.lives]
        FUNC.END

;paint_shield(dword row.offset, dword col.offset)
paint_shield:
    FUNC.START
    RESERVE(2)
    CALL delay, shield_animation.timer, 300   ;the form of the shield change every 300ms
    cmp eax, 0
    je shield_cont

    cmp byte [shield_graphics.style], 1
    je set.shield_form2
    jmp set.shield_form1

    shield_cont:

    mov ecx, 0    
    shield_while:
        cmp ecx, 21 * 4
        jnl shield_while.end
        
        mov eax, [PARAM(0)]
        add eax, [shield_rows + ecx]
        cmp eax, 0
        jle painted
        cmp eax, 25
        jge painted
        mov [LOCAL(0)], eax        

        mov eax, [PARAM(1)]
        add eax, [shield_cols + ecx]
        cmp eax, 0
        jle painted
        cmp eax, 80
        jge painted
        mov [LOCAL(1)], eax

        push ecx
        CALL video.print, [shield_graphics + ecx], [LOCAL(0)], [LOCAL(1)]
        pop ecx

        painted:
        add ecx, 4
        jmp shield_while
        shield_while.end:
        FUNC.END
    
    set.shield_form2:
        mov byte [shield_graphics.style], 0
        mov dword [shield_graphics], '/'|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 4], ' '|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 8], '-'|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 12], ' '|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 16], '-'|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 20], ' '|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 24], '\'|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 28], ' '|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 52], ' '|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 56], '\'|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 60], ' '|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 64], '_'|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 68], ' '|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 72], '_'|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 76], ' '|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 80], '/'|FG.YELLOW|BG.BLACK
        jmp shield_cont


    set.shield_form1:
        mov byte [shield_graphics.style], 1
        mov dword [shield_graphics], ' '|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 4], '-'|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 8], ' '|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 12], '-'|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 16], ' '|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 20], '-'|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 24], ' '|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 28], '|'|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 52], '|'|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 56], ' '|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 60], '_'|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 64], ' '|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 68], '_'|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 72], ' '|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 76], '_'|FG.YELLOW|BG.BLACK
        mov dword [shield_graphics + 80], ' '|FG.YELLOW|BG.BLACK
        jmp shield_cont
