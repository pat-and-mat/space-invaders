%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"

extern enemy_blue.update
extern enemy_blue.init
extern enemy_blue.paint
extern enemy_red.update
extern enemy_red.init
extern enemy_red.paint
extern enemy_yellow.update
extern enemy_yellow.init
extern enemy_yellow.paint

section .text

; init()
; generate an enemie
global enemy.generate
enemy.generate:
    FUNC.START
    FUNC.END

; update()
; It is here where all the actions related to this object will be taking place
global enemy.update
enemy.update:
    FUNC.START
    call enemy_blue.update
    call enemy_red.update
    call enemy_yellow.update
    FUNC.END

; paint()
; Puts the object's graphics in the canvas
global enemy.paint
enemy.paint:
    FUNC.START
    call enemy_blue.paint
    call enemy_red.paint
    call enemy_yellow.paint
    FUNC.END

; enemy.take_damage(dword damage)
; Takes lives away from enemies
global enemy.take_damage
enemy.take_damage:
    FUNC.START
    FUNC.END
