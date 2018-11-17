%include "video.inc"
%include "keyboard.inc"
%include "stack.inc"

section .text

extern video.clear
extern scan
extern calibrate
extern player.paint
extern player.init
extern video.print
extern player.update

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
  CALL player.init, 1, 20, 38, 1

  ; Snakasm main loop
  game.loop:
    .input:
      call get_input
      
      ; call player.update
      call player.paint

    ; Main loop.

    ; Here is where you should place your game's logic.
    ; Develop procedures like paint_map and update_content,
    ; declare them extern and use them here.

    jmp game.loop


move.up:
  CALL player.update, dword "up"
  ret

move.down:
  CALL player.update, dword "down"
  ret

move.left:
  CALL player.update, dword "left"
  ret


move.right:
  CALL player.update, dword "right"
  ret


get_input:
    call scan
    push eax
    ; The value of the input is on 'dword [esp]'

    ; Your bindings here    
    bind KEY.UP, move.up
    bind KEY.DOWN, move.down
    bind KEY.LEFT, move.left
    bind KEY.RIGHT, move.right

    add esp, 4 ; free the stack
    ret
