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

extern rand
extern delay

section .bss

timer resd 2

section .text

;0-blue, 1-red, 2-yellow
; generate(dword number * 4, dword col, dword color)
; generate an enemie
global enemy.generate
enemy.generate:
    FUNC.START

    mov ecx, [PARAM(0)]

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

    ;the enemies are generate in the upper section of the screen
    blue:
    CALL enemy_blue.init, 2, eax
    jmp Continue

    red:
    CALL enemy_red.init, 2, eax
    jmp Continue
    
    yellow:
    CALL enemy_yellow.init, 1, eax
    jmp Continue

; update()
; It is here where all the actions related to this object will be taking place
global enemy.update
enemy.update:
    FUNC.START
    RESERVE(3)
    
    CALL delay, timer, 3000  ;timing condition to generate
    cmp eax, 0
    je end

    
    CALL rand, 5   ;max number of enemy generate 
    mov edx, dword 4
    mul edx  
    mov [LOCAL(0)], eax
    mov ebx, 20      
    sub ebx, eax
    CALL rand, ebx
    mov edx, dword 4
    mul edx 
    mov [LOCAL(1)], eax
    CALL rand, COLORS
    mov [LOCAL(2)], eax
    CALL enemy.generate, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)]

    end:      
    
    call enemy_blue.update
    call enemy_red.update
    call enemy_yellow.update
    
    FUNC.END

; paint()
; Puts the object's graphics in the canvas
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


