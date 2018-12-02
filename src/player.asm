%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"
%include "sound.inc"

extern video.print
extern weapons.shoot
extern input
extern beep.on
extern beep.set
extern beep.of
extern delay
extern play_shoot
extern play_player_die
extern menu.lose
extern sound_player_die.update
extern sound.timer
extern beep.of

%define SHIP.COORDS 5

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

graphics dd '/'|FG.GRAY|BG.BLACK,\
            '-'|FG.GRAY|BG.BLACK,\
            '^'|FG.GRAY|BG.BLACK,\
            '-'|FG.GRAY|BG.BLACK,\
            '\'|FG.GRAY|BG.BLACK,\
 
            
rows dd 0, 0, 0, 0, 0
cols dd 0, 1, 2, 3, 4

row.top dd 0
row.bottom dd 0

col.left dd 0
col.right dd 3

weapon.row dd 0
weapon.col dd 2

graphics.style db 0

section .bss

global lives
lives resw 1

row.offset resd 1
col.offset resd 1

animation.timer resd 2
lose.timer resd 2

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
    RESERVE(2)

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
        call play_shoot

        mov dword [graphics + 8], 173|FG.GRAY|BG.BLACK
        mov dword [animation.timer], 0

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
        FUNC.END

; collision(dword hash, dword row, dword col)
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
; Takes lives away from player
; returns 1 if player remains alive after damage, 0 otherwise
global player.take_damage
player.take_damage:
    FUNC.START
    
    mov eax, [PARAM(0)]
    cmp [lives], ax
    jng .destroyed
    sub [lives], ax
    jmp alive

    .destroyed:

        mov eax, 0
        mov word [lives], 0
        
        wait_for:
        call sound_player_die.update   ;freeze the screen 1500ms and make lose sound
        CALL delay, lose.timer, 1500
        cmp eax, 0
        je wait_for
        call beep.of
        
        call menu.lose
        
        jmp end

    alive:
        mov eax, 1

    end:
        FUNC.END
