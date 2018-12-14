%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"

%define COLORS 3

extern bonus_lives.update
extern bonus_lives.init
extern bonus_lives.paint
extern bonus_lives.reset
extern bonus_shield.update
extern bonus_shield.init
extern bonus_shield.paint
extern bonus_weapon1.update
extern bonus_weapon1.init
extern bonus_weapon1.paint
extern bonus_shield.reset
extern bonus_weapon1.reset
extern bonus_weapon2.update
extern bonus_weapon2.init
extern bonus_weapon2.paint
extern bonus_weapon2.reset
extern bonus_AI.update
extern bonus_AI.init
extern bonus_AI.paint
extern bonus_AI.reset

extern bonus_time
extern boss_time

extern rand
extern delay

section .data

section .bss

timer resd 2

section .text

;0-lives, 1-shield, 2-weapon1 3-weapon2
; generate(dword row, dword color)
; generate an enemie
global bonus.generate
bonus.generate:
    FUNC.START
    mov eax, [PARAM(0)]  
    cmp [PARAM(1)], dword 0  ;type of ships to generate
    je lives
    cmp [PARAM(1)], dword 1
    je shield
    cmp [PARAM(1)], dword 2
    je weapon1
    cmp [PARAM(1)], dword 3
    je weapon2
    cmp [PARAM(1)], dword 4
    je ai
    continue:
    FUNC.END

    ;the bonus are generate in the sides of the screen
    lives:
    CALL bonus_lives.init, eax, 79
    jmp continue

    shield:
    CALL bonus_shield.init, eax, 1
    jmp continue
    
    weapon1:
    CALL bonus_weapon1.init, eax, 79
    jmp continue

    weapon2:
    CALL bonus_weapon2.init, eax, 1
    jmp continue

    ai:
    CALL bonus_AI.init, eax, 1
    jmp continue

; update(dword map)
; It is here where all the actions related to this object will be taking place
global bonus.update
bonus.update:
    FUNC.START
    RESERVE(2)
    
    CALL delay, timer, [bonus_time]  ;timing condition to generate
    cmp eax, 0
    je end

    CALL rand, 20
    add eax, 2
    mov [LOCAL(0)], eax   ;LOCAL(0) = col to generate the bonus

    CALL rand, 5
    mov [LOCAL(1)], eax  ;LOCAL(1) = type of bonus to generate
    CALL bonus.generate, [LOCAL(0)], [LOCAL(1)]

    end:      
    
    CALL bonus_lives.update, [PARAM(0)]
    CALL bonus_shield.update, [PARAM(0)]
    CALL bonus_weapon1.update, [PARAM(0)]
    CALL bonus_weapon2.update, [PARAM(0)]
    CALL bonus_AI.update, [PARAM(0)]
    FUNC.END

; paint()
; Put the object's graphics in the canvas
global bonus.paint
bonus.paint:
    FUNC.START
    call bonus_lives.paint    ;each subprogram paint all the ships of the mentioned color
    call bonus_shield.paint
    call bonus_weapon1.paint
    call bonus_weapon2.paint
    call bonus_AI.paint
    FUNC.END

; bonus_manager.reset()
; reset all the bonus
global bonus_manager.reset
bonus_manager.reset:
    FUNC.START
    call bonus_lives.reset
    call bonus_shield.reset
    call bonus_weapon1.reset
    call bonus_weapon2.reset
    call bonus_AI.reset
    FUNC.END


