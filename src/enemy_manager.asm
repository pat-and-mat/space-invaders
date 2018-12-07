%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"

%define COLORS 3

extern enemy_blue.update
extern enemy_blue.init
extern enemy_blue.paint
extern enemy_red.update
extern enemy_red.init
extern enemy_red.paint
extern enemy_yellow.update
extern enemy_yellow.init
extern enemy_yellow.paint
extern enemy_blue.reset
extern enemy_red.reset
extern enemy_yellow.reset

extern colors
extern colors_count
extern generate_time
extern generate_amount
extern bonus_time
extern boss_time

extern rand
extern delay

section .data

section .bss

timer resd 2

section .text

;0-blue, 1-red, 2-yellow
; generate(dword number, dword col, dword color)
; generate an enemie
global enemy.generate
enemy.generate:
    FUNC.START

    mov ecx, [PARAM(0)]
    shl ecx, 2
    while:
        mov eax, [PARAM(1)]  ;number of ships to generate
        add eax, ecx
        cmp [PARAM(2)], dword 0  ;type of ships to generate
        je blue
        cmp [PARAM(2)], dword 1
        je red
        cmp [PARAM(2)], dword 2
        je yellow

        Continue:

        cmp ecx, dword 0
        jng end.while
        sub ecx, dword 4
        jmp while

    end.while:
    FUNC.END

    ;the enemies are generate in the top section of the screen
    blue:
    CALL enemy_blue.init, 1, eax
    jmp Continue

    red:
    CALL enemy_red.init, 1, eax
    jmp Continue
    
    yellow:
    CALL enemy_yellow.init, 1, eax
    jmp Continue

; update(dword map)
; It is here where all the actions related to this object will be taking place
global enemy.update
enemy.update:
    FUNC.START
    RESERVE(3)
    
    CALL delay, timer, [generate_time]  ;timing condition to generate
    cmp eax, 0
    je end

    
    CALL rand, [generate_amount]   ;max number of enemy generate 
    mov [LOCAL(0)], eax  ;LOCAL(0) = number of enemies to generate
    
    mov ebx, 20 
    sub ebx, eax
    CALL rand, ebx
    shl eax, 2 
    mov ebx, [LOCAL(0)]
    shl ebx, 2
    add eax, ebx
    mov [LOCAL(1)], eax  ;LOCAL(1) = col to generate the enemies

    CALL rand, [colors_count]
    shl eax, 2
    mov ebx, [colors + eax]
    mov [LOCAL(2)], ebx  ;LOCAL(2) = color of enemy to generate
    CALL enemy.generate, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)]

    end:      
    
    CALL enemy_blue.update, [PARAM(0)]
    CALL enemy_red.update, [PARAM(0)]
    CALL enemy_yellow.update, [PARAM(0)]
    
    FUNC.END

; paint()
; Put the object's graphics in the canvas
global enemy.paint
enemy.paint:
    FUNC.START
    call enemy_blue.paint    ;each subprogram paint all the ships of the mentioned color
    call enemy_red.paint
    call enemy_yellow.paint
    FUNC.END

; enemy.take_damage(dword damage)
; Takes lives away from enemies
global enemy.take_damage
enemy.take_damage:
    FUNC.START
    FUNC.END

; enemy_manager.reset()
; reset all the enemies
global enemy_manager.reset
enemy_manager.reset:
    FUNC.START
    call enemy_blue.reset
    call enemy_red.reset
    call enemy_yellow.reset
    FUNC.END


