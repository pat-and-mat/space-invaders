%include "video.inc"
%include "stack.inc"
%include "hash.inc"
%include "utils.inc"

%macro CLEAR_MAP 1
    mov eax, %1
    mov ecx, COLS * ROWS
    mov edi, map
    cld
    rep stosd
%endmacro

%macro CLEAR_OLD_MAP 1
    mov eax, %1
    mov ecx, COLS * ROWS
    mov edi, old_map
    cld
    rep stosd
%endmacro

section .data

collisions.hashes1 times ROWS*COLS dd 0
collisions.hashes2 times ROWS*COLS dd 0
collisions.count dw 0

global debug_info
debug_info times 80 dw 0

section .bss

map resd COLS * ROWS
;the old map is used to check can_move
global old_map
old_map resd COLS * ROWS

section .text

extern array.index_of

extern player.init

extern player.update
extern weapons.update
extern enemy.update
extern sound.update

extern info.paint

extern player.collision
extern weapons.collision
extern enemy_yellow.collision
extern enemy_red.collision
extern enemy_blue.collision

extern player.paint
extern weapons.paint
extern enemy.paint
extern video.clear
extern video.refresh
extern video.print
extern delay

; debug
extern video.set_rect

extern enemy_manager.reset
extern weapons.reset

; update()
; It is here where all the actions related to this object will be taking place
engine.update:
    FUNC.START
    
    CLEAR_OLD_MAP 0
    mov esi, map
    mov edi, old_map
    mov ecx, ROWS * COLS
    cld
    rep movsd

    CLEAR_MAP 0
    CALL player.update, map
    CALL weapons.update, map
    CALL enemy.update, map
    call sound.update
    FUNC.END

; paint()
; Puts the object's graphics in the screen
engine.paint:
    FUNC.START
    CALL video.clear, BG.BLACK
    call player.paint
    call weapons.paint
    call enemy.paint
    call info.paint
    call video.refresh    
    FUNC.END

; ******************************************************************************************
; * Collisions                                                                             *
; ******************************************************************************************

; collision()
; It is here where collisions will be handled
engine.collision:
    FUNC.START
    RESERVE(3)  ; i, hash1, hash2

    mov dword[LOCAL(0)], 0
    .collision.while:
        mov ecx, [LOCAL(0)]

        cmp cx, [collisions.count]
        je .collision.while.end

        shl ecx, 2

        mov eax, [collisions.hashes1 + ecx]
        mov [LOCAL(1)], eax

        mov eax, [collisions.hashes2 + ecx]
        mov [LOCAL(2)], eax

        CALL engine.handle_collision, [LOCAL(1)], [LOCAL(2)]

            inc dword [LOCAL(0)]
    .collision.while.end:

    mov word [collisions.count], 0
    FUNC.END

; engine.handle_collision(dword i, dword j)
engine.handle_collision:
    FUNC.START
    RESERVE(4)  ; hash1, inst1, hash2, inst2

    xor eax, eax

    mov ax, [PARAM(0)]
    mov [LOCAL(1)], eax

    mov ax, [PARAM(0) + 2]
    mov [LOCAL(0)], eax

    mov ax, [PARAM(1)]
    mov [LOCAL(3)], eax

    mov ax, [PARAM(1) + 2]
    mov [LOCAL(2)], eax

    CALL engine.invoke_handler, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)], [LOCAL(3)]
    CALL engine.invoke_handler, [LOCAL(2)], [LOCAL(3)], [LOCAL(0)], [LOCAL(1)]

    FUNC.END

; engine.invoke_handler(dword hash, dword inst, dword hash_other, dword inst_other)
; Invokes the corresponding handler to handle the given collision
engine.invoke_handler:
    FUNC.START
    cmp dword [PARAM(0)], HASH.PLAYER
    je .handler.player

    cmp dword [PARAM(0)], HASH.SHOT
    je .handler.shot

    cmp dword [PARAM(0)], HASH.ENEMY_YELLOW
    je .handler.enemy_yellow

    cmp dword [PARAM(0)], HASH.ENEMY_RED
    je .handler.enemy_red

    cmp dword [PARAM(0)], HASH.ENEMY_BLUE
    je .handler.enemy_blue

    jmp .handler.end

    .handler.player:
    CALL player.collision, [PARAM(2)], [PARAM(3)]
    jmp .handler.end

    .handler.shot:
    CALL weapons.collision, [PARAM(1)], [PARAM(2)], [PARAM(3)]
    jmp .handler.end

    .handler.enemy_yellow:
    CALL enemy_yellow.collision, [PARAM(1)], [PARAM(2)], [PARAM(3)]
    jmp .handler.end

    .handler.enemy_red:
    CALL enemy_red.collision, [PARAM(1)], [PARAM(2)], [PARAM(3)]
    jmp .handler.end

    .handler.enemy_blue:
    CALL enemy_blue.collision, [PARAM(1)], [PARAM(2)], [PARAM(3)]
    jmp .handler.end

    .handler.end:
        FUNC.END

; enine.add_collision(dword hash1, dword hash2)
; Adds a collision
global engine.add_collision
engine.add_collision:
    FUNC.START
    RESERVE(1)  ; i

    CALL engine.find_hashes, [PARAM(0)], [PARAM(1)]
    
    cmp ax, [collisions.count]
    jne .add_collision.end

    CALL engine.find_hashes, [PARAM(0)], [PARAM(1)]

    cmp ax, [collisions.count]
    jne .add_collision.end

    xor ecx, ecx
    mov cx, [collisions.count]
    shl ecx, 2
    mov eax, [PARAM(0)]
    mov [collisions.hashes1 + ecx], eax

    xor ecx, ecx
    mov cx, [collisions.count]
    shl ecx, 2
    mov eax, [PARAM(1)]
    mov [collisions.hashes2 + ecx], eax

    inc word [collisions.count]

    .add_collision.end:
        FUNC.END

; engine.find_hashes(dword hash1, dword hash2)
; finds the given pair of hashes in collisions
engine.find_hashes:
    FUNC.START
    RESERVE(1)

    mov dword[LOCAL(0)], 0
    .find_hashes.while:
        mov ecx, [LOCAL(0)]

        cmp cx, [collisions.count]
        je .find_hashes.while.end

        shl ecx, 2

        mov eax, [collisions.hashes1 + ecx]
        cmp eax, [PARAM(0)]
        jne .find_hashes.while.cont

        mov eax, [collisions.hashes2 + ecx]
        cmp eax, [PARAM(1)]
        jne .find_hashes.while.cont

        jmp .find_hashes.while.end

        .find_hashes.while.cont:
            inc dword [LOCAL(0)]
    .find_hashes.while.end:
    mov eax, [LOCAL(0)]

        FUNC.END

; *******************************************************************************************

; engine.start()
; Initializes the game
global engine.start
engine.start:
    FUNC.START
    CALL player.init, 25, 20, 38
    call enemy_manager.reset
    call weapons.reset
    FUNC.END

; engine.run()
; Runs a whole iteration of the engine
global engine.run
engine.run:
    FUNC.START
    call engine.update
    call engine.collision
    call engine.paint
    ; call engine.debug
    FUNC.END

engine.debug:
    FUNC.START
    CALL video.set_rect, debug_info, 24, 0, 1, 80
    call video.refresh

    mov edi, debug_info
    mov eax, 0
    mov ecx, 80
    cld
    rep stosw

    FUNC.END





    