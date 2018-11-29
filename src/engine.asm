%include "video.inc"
%include "stack.inc"
%include "hash.inc"

%macro CLEAR 2
    mov ax, %2
    mov ecx, COLS * ROWS
    mov edi, %1
    cld
    rep stosw
%endmacro

section .data

collisions.hashes times ROWS*COLS dw 0
collisions.insts times ROWS*COLS dw 0
collisions.count dw 0

section .bss

map resw COLS * ROWS

section .text

extern array.shiftr

extern player.init

extern player.update
extern weapons.update
extern enemy.update

extern player.collision
extern weapons.collision

extern weapons.instof

extern player.paint
extern weapons.paint
extern enemy.paint
extern video.clear
extern video.refresh

; update()
; It is here where all the actions related to this object will be taking place
engine.update:
    FUNC.START
    CLEAR map, 0
    CALL player.update, map
    CALL weapons.update, map
    CALL enemy.update, map
    FUNC.END

; paint()
; Puts the object's graphics in the screen
engine.paint:
    FUNC.START
    CALL video.clear, BG.BLACK
    call player.paint
    call weapons.paint
    call enemy.paint
    call video.refresh
    FUNC.END

; **************
; * Collisions *
; **************

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

        mov eax, [LOCAL(0)]
        inc eax
        mov [LOCAL(1)], eax
        .obj2.while:
            mov ecx, [LOCAL(1)]
            cmp cx, [collisions.count]
            je .obj2.while.end

            shl ecx, 1

            mov eax, [collisions.hashes + ecx]
            cmp ax, -1
            je .obj2.while.end

            CALL engine.handle_collisions, [LOCAL(0)], [LOCAL(1)]

            inc dword [LOCAL(1)]
            jmp .obj2.while
        .obj2.while.end:

        inc dword [LOCAL(0)]
        jmp .obj1.while    
    .obj1.while.end:

    FUNC.END

; engine.handle_collisions(dword i, dword j)
engine.handle_collisions:
    FUNC.START
    RESERVE(4)  ; hash1, inst1, hash2, inst2

    mov ecx, [PARAM(0)]
    shl ecx, 1

    xor eax, eax

    mov ax, [collisions.hashes + ecx]
    mov [LOCAL(0)], eax

    mov ax, [collisions.insts + ecx]
    mov [LOCAL(1)], eax

    mov ecx, [PARAM(1)]
    shl ecx, 1

    mov ax, [collisions.hashes + ecx]
    mov [LOCAL(2)], eax

    mov ax, [collisions.insts + ecx]
    mov [LOCAL(3)], eax

    .hash1:
        cmp dword [LOCAL(0)], HASH.PLAYER
        je .hash1.player

        cmp dword [LOCAL(0)], HASH.ENEMY
        je .hash1.enemy

        cmp dword [LOCAL(0)], HASH.SHOT
        je .hash1.shot

        .hash1.player:
        CALL player.collision, [LOCAL(2)], [LOCAL(3)]
        jmp .hash2

        .hash1.enemy:
        ; CALL enemy.collision, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)], [LOCAL(3)]
        jmp .hash2

        .hash1.shot:
        CALL weapons.collision, [LOCAL(1)], [LOCAL(2)], [LOCAL(3)]
        jmp .hash2

    .hash2:
        cmp dword [LOCAL(0)], HASH.PLAYER
        je .hash2.player

        cmp dword [LOCAL(0)], HASH.ENEMY
        je .hash2.enemy

        cmp dword [LOCAL(0)], HASH.SHOT
        je .hash2.shot

        .hash2.player:
        CALL player.collision, [LOCAL(0)], [LOCAL(1)]
        jmp .handle.end

        .hash2.enemy:
        ; CALL enemy.collision, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)], [LOCAL(3)]
        jmp .handle.end

        .hash2.shot:
        CALL weapons.collision, [LOCAL(3)], [LOCAL(0)], [LOCAL(1)]
        jmp .handle.end

    .handle.end:
        FUNC.END

; enine.add_collision(dword hash1, dword hash2, dword row, dword col)
; Adds a collision where hash2 is already in the map and hash1 is colliding with it
global engine.add_collision
engine.add_collision:
    FUNC.START
    RESERVE(3)  ; inst1, inst2, i

    CALL engine.get_inst, [PARAM(0)], [PARAM(2)], [PARAM(3)]
    mov [LOCAL(0)], eax
    CALL engine.get_inst, [PARAM(1)], [PARAM(2)], [PARAM(3)]
    mov [LOCAL(1)], eax

    mov dword [LOCAL(2)], 0
    .collisions.while:
        mov ecx, [LOCAL(2)]
        cmp cx, [collisions.count]
        je .collisions.while.end

        shl ecx, 1

        xor eax, eax
        mov ax, [collisions.hashes + ecx]

        cmp ax, -1
        je .collisions.while.cont

        cmp eax, [PARAM(1)]
        jne .collisions.while.cont

        mov ax, [collisions.insts + ecx]
        cmp eax, [LOCAL(1)]
        jne .collisions.while.cont

        jmp .collisions.while.end

        .collisions.while.cont:
            inc dword [LOCAL(2)]
            jmp .collisions.while
    .collisions.while.end:

    mov eax, [LOCAL(2)]
    cmp ax, [collisions.count]
    jne .found

    xor ecx, ecx
    mov cx, [collisions.count]
    shl ecx, 1
    mov word [collisions.hashes + ecx], -1
    mov word [collisions.insts + ecx], -1
    inc word [collisions.count]

    xor ecx, ecx
    mov cx, [collisions.count]
    shl ecx, 1
    mov eax, [PARAM(1)]
    mov word [collisions.hashes + ecx], ax
    mov eax, [PARAM(0)]
    mov word [collisions.insts + ecx], ax
    inc word [collisions.count]

    xor ecx, ecx
    mov cx, [collisions.count]
    shl ecx, 1
    mov eax, [LOCAL(1)]
    mov word [collisions.hashes + ecx], ax
    mov eax, [LOCAL(0)]
    mov word [collisions.insts + ecx], ax
    inc word [collisions.count]

    jmp .add_collision.end

    .found:
        inc dword [LOCAL(2)]

        xor eax, eax
        mov ax, [collisions.count]
        CALL array.shiftr, collisions.hashes, eax, [LOCAL(2)]

        xor eax, eax
        mov ax, [collisions.count]
        CALL array.shiftr, collisions.insts, eax, [LOCAL(2)]

        inc word [collisions.count]
        jmp .add_collision.end

    .add_collision.end:
        FUNC.END

; engine.get_inst(dword hash, dword row, dword col)
engine.get_inst:
    FUNC.START

    cmp dword [PARAM(0)], HASH.PLAYER
    je .hash.player

    cmp dword [PARAM(0)], HASH.ENEMY
    je .hash.enemy

    cmp dword [PARAM(0)], HASH.SHOT
    je .hash.shot

    .hash.player:
    mov eax, 0
    jmp .get_inst.end

    .hash.enemy:
    ; CALL enemy.instof, [PARAM(1)], [PARAM(2)]
    jmp .get_inst.end

    .hash.shot:
    CALL weapons.instof, [PARAM(1)], [PARAM(2)]
    jmp .get_inst.end

    .get_inst.end:
        FUNC.END

; engine.start()
; Initializes the game
global engine.start
engine.start:
    FUNC.START
    CALL player.init, 100, 20, 38
    FUNC.END

; engine.run()
; Runs a whole iteration of the engine
global engine.run
engine.run:
    FUNC.START
    call engine.update
    call engine.collision
    call engine.paint
    FUNC.END