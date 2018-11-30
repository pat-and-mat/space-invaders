%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"
%include "utils.inc"
%include "hash.inc"

extern video.print
extern weapons.shoot
extern engine.add_collision
extern input

%define SHIP.COORDS 6

%macro SHIP.ROW 1
    xor eax, eax
    mov ax, [row.offset]
    add ax, %1
%endmacro

%macro SHIP.COL 1
    xor eax, eax
    mov ax, [col.offset]
    add ax, %1
%endmacro

; Data section is meant to hold constant values, do not modify
section .data

graphics dd 'M'|FG.GRAY|BG.BLACK,\
            '['|FG.GRAY|BG.BLACK,\
            ']'|FG.GRAY|BG.BLACK,\
            '^'|FG.GRAY|BG.BLACK,\
            'W'|FG.GRAY|BG.BLACK,\
            'W'|FG.GRAY|BG.BLACK,
            
rows dd 0, 1, 1, 2, 2, 2
cols dd 1, 0, 2, 1, 0, 2

row.top dd 0
row.bottom dd 3

col.left dd 0
col.right dd 3

weapon.row dd 0
weapon.col dd 1

section .bss

lives resw 1

row.offset resd 1
col.offset resd 1

section .text

; init(word lives, dword r.offset, dword c.offset)
; Initialize player
global player.init
player.init:
    FUNC.START
    ;filling local vars of player
    mov bx, [PARAM(0)]
    mov [lives], bx
    
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
    RESERVE(3)

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
        sub dword [row.offset], 1
        jmp update.end

    down:
        add dword [row.offset], 1
        jmp update.end

    left:
        sub dword [col.offset], 1
        jmp update.end

    right:
        add dword [col.offset], 1
        jmp update.end

    space:
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
    FUNC.END

; paint()
; Puts the object's graphics in the screen
global player.paint
player.paint:
    FUNC.START
    RESERVE(2)

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

; player.take_damage(dword damage)
; Takes lives away from player
; returns 1 if player remains alive after damage, 0 otherwise
global player.take_damage
player.take_damage:
    FUNC.START
    
    mov eax, [PARAM(0)]
    cmp [lives], ax
    jng .destroyed
    sub [lives], ax
    jmp .alive

    .destroyed:
        mov eax, 0
        mov word [lives], 0
        ; TODO: do something if player is destroyed
        jmp .end

    .alive:
        mov eax, 1

    .end:
        FUNC.END
