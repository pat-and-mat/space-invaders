%include "video.inc"
%include "stack.inc"
%include "hash.inc"

%macro CLEAR_MAP 1
    mov eax, %1
    mov ecx, COLS * ROWS
    mov edi, map
    cld
    rep stosd
%endmacro

section .data

collisions.hashes times ROWS*COLS dd 0
collisions.count dw 0

global debug_info
debug_info times 80 dw 0

section .bss

map resd COLS * ROWS

section .text

extern array.shiftr
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

; debug
extern video.set_rect

extern enemy_manager.reset
extern weapons.reset

; update()
; It is here where all the actions related to this object will be taking place
engine.update:
    FUNC.START
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
    RESERVE(2)  ; i, j

    mov dword [LOCAL(0)], 0
    .obj1.while:
        mov ecx, [LOCAL(0)]
        cmp cx, [collisions.count]
        je .obj1.while.end

        shl ecx, 2

        cmp dword [collisions.hashes + ecx], -1
        je .obj1.while.cont

        mov eax, [LOCAL(0)]
        inc eax
        mov [LOCAL(1)], eax
        .obj2.while:
            mov ecx, [LOCAL(1)]
            cmp cx, [collisions.count]
            je .obj2.while.end

            shl ecx, 2

            cmp dword [collisions.hashes + ecx], -1
            je .obj2.while.end

            CALL engine.handle_collision, [LOCAL(0)], [LOCAL(1)]

            inc dword [LOCAL(1)]
            jmp .obj2.while
        .obj2.while.end:

        .obj1.while.cont:
            inc dword [LOCAL(0)]
            jmp .obj1.while    
    .obj1.while.end:

    mov word [collisions.count], 0
    FUNC.END

; engine.handle_collision(dword i, dword j)
engine.handle_collision:
    FUNC.START
    RESERVE(4)  ; hash1, inst1, hash2, inst2

    xor eax, eax

    mov ecx, [PARAM(0)]
    shl ecx, 2

    mov ax, [collisions.hashes + ecx]
    mov [LOCAL(1)], eax

    add ecx, 2

    mov ax, [collisions.hashes + ecx]
    mov [LOCAL(0)], eax

    mov ecx, [PARAM(1)]
    shl ecx, 2

    mov ax, [collisions.hashes + ecx]
    mov [LOCAL(3)], eax

    add ecx, 2

    mov ax, [collisions.hashes + ecx]
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

; enine.add_collision(dword hash_new, dword hash_old)
; Adds a collision where hash_old is already in the map and hash_new is colliding with it
global engine.add_collision
engine.add_collision:
    FUNC.START
    RESERVE(1)  ; i

    xor eax, eax
    mov ax, [collisions.count]
    CALL array.index_of, collisions.hashes, eax, [PARAM(1)], 4
    mov [LOCAL(0)], eax

    cmp ax, [collisions.count]
    jne .found

    ; not found
    xor ecx, ecx
    mov cx, [collisions.count]
    shl ecx, 2
    mov eax, [PARAM(0)]
    mov [collisions.hashes + ecx], eax
    inc word [collisions.count]

    xor ecx, ecx
    mov cx, [collisions.count]
    shl ecx, 2
    mov eax, [PARAM(1)]
    mov [collisions.hashes + ecx], eax
    inc word [collisions.count]

    xor ecx, ecx
    mov cx, [collisions.count]
    shl ecx, 2
    mov dword [collisions.hashes + ecx], -1
    inc word [collisions.count]

    jmp .add_collision.end

    .found:
        inc dword [LOCAL(0)]

        xor eax, eax
        mov ax, [collisions.count]
        CALL array.shiftr, collisions.hashes, eax, [LOCAL(0)]

        mov ecx, [LOCAL(0)]
        shl ecx, 2
        mov eax, [PARAM(0)]
        mov [collisions.hashes + ecx], eax

        inc word [collisions.count]
        jmp .add_collision.end

    .add_collision.end:
        FUNC.END

; *******************************************************************************************

; engine.start()
; Initializes the game
global engine.start
engine.start:
    FUNC.START
    CALL player.init, 50, 20, 38
    FUNC.END

; engine.run()
; Runs a whole iteration of the engine
global engine.run
engine.run:
    FUNC.START
    call engine.update
    call engine.collision
    call engine.paint
    call engine.debug
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

;engine.reset()
;reset the game
global engine.reset
engine.reset:
    FUNC.START
    CALL player.init, 50, 20, 38
    call enemy_manager.reset
    call weapons.reset
    FUNC.END