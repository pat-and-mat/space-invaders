%include "video.inc"
%include "keyboard.inc"

section .text

extern video.clear
extern scan
extern calibrate

; Bind a key to a procedure
%macro bind 2
  cmp byte [esp], %1
  jne %%next
  call %2
  %%next:
%endmacro

; Fill the screen with the given background color
%macro FILL_SCREEN 1
  push word %1
  call video.clear
  add esp, 2
%endmacro

global game
game:
  ; Initialize game

  FILL_SCREEN BG.BLACK

  ; Calibrate the timing
  call calibrate

  ; Game main loop
  game.loop:
    .input:
      call get_input

    ; Main loop.

    ; Here is where you should place your game's logic.
    ; Develop procedures like paint_map and update_content,
    ; declare them extern and use them here.

    jmp game.loop


draw.red:
  FILL_SCREEN BG.RED
  ret


draw.green:
  FILL_SCREEN BG.GREEN
  ret


get_input:
    call scan
    push ax
    ; The value of the input is on 'word [esp]'

    ; Your bindings here
    bind KEY.UP, draw.green
    bind KEY.DOWN, draw.red

    add esp, 2 ; free the stack
    ret
