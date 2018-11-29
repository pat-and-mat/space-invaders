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
extern screen
%macro PRINT_MAP 0
    mov ecx, COLS * ROWS
    mov esi, map
    mov edx, 0
    cld
    .aaaa:
        lodsd
        shr eax, 8
        or ax, BG.RED
        mov [screen + edx], ax
        add edx, 2  
        loop .aaaa
    call video.refresh
%endmacro

section .data

collisions.hashes times ROWS*COLS dd 0
collisions.count dw 0

section .bss

map resd COLS * ROWS

section .text

extern array.shiftr

extern player.init

extern player.update
extern weapons.update
extern enemy.update

extern player.collision
extern weapons.collision

extern player.paint
extern weapons.paint
extern enemy.paint
extern video.clear
extern video.refresh
extern video.print

; update()
; It is here where all the actions related to this object will be taking place
engine.update:
    FUNC.START
    CLEAR_MAP 0
    mov word [collisions.count], 0
    CALL player.update, map
    CALL weapons.update, map
    ; PRINT_MAP
    ; CALL enemy.update, map
    FUNC.END

; paint()
; Puts the object's graphics in the screen
engine.paint:
    FUNC.START
    CALL video.clear, BG.BLACK
    call player.paint
    call weapons.paint
    call enemy.paint

    xor eax, eax
    mov ax, [collisions.count]
    add eax, 48
    or eax, FG.RED
    CALL video.print, eax, 24, 79

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

        shl ecx, 2

        cmp dword [collisions.hashes], -1
        je .obj1.while.cont

        mov eax, [LOCAL(0)]
        inc eax
        mov [LOCAL(1)], eax
        .obj2.while:
            mov ecx, [LOCAL(1)]
            cmp cx, [collisions.count]
            je .obj2.while.end

            shl ecx, 2

            mov eax, [collisions.hashes + ecx]
            cmp ax, -1
            je .obj2.while.end

            CALL engine.handle_collisions, [LOCAL(0)], [LOCAL(1)]

            inc dword [LOCAL(1)]
            jmp .obj2.while
        .obj2.while.end:

        .obj1.while.cont:
            inc dword [LOCAL(0)]
            jmp .obj1.while    
    .obj1.while.end:

    FUNC.END

; engine.handle_collisions(dword i, dword j)
engine.handle_collisions:
    FUNC.START
    RESERVE(4)  ; hash1, inst1, hash2, inst2

    mov ecx, [PARAM(0)]
    shl ecx, 2

    xor edx, edx

    mov eax, [collisions.hashes + ecx]
    
    mov dx, ax
    mov [LOCAL(1)], edx

    shr eax, 8

    mov dx, ax
    mov [LOCAL(0)], edx

    mov ecx, [PARAM(1)]
    shl ecx, 2

    xor edx, edx

    mov eax, [collisions.hashes + ecx]
    
    mov dx, ax
    mov [LOCAL(2)], edx

    shr eax, 8

    mov dx, ax
    mov [LOCAL(3)], edx

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

; enine.add_collision(dword hash1, dword hash2)
; Adds a collision where hash2 is already in the map and hash1 is colliding with it
global engine.add_collision
engine.add_collision:
    FUNC.START
    RESERVE(1)  ; i

    mov dword [LOCAL(0)], 0
    .collisions.while:
        mov ecx, [LOCAL(0)]
        cmp cx, [collisions.count]
        je .collisions.while.end

        shl ecx, 2

        mov eax, [collisions.hashes + ecx]
        cmp eax, [PARAM(1)]
        je .collisions.while.end

        inc dword [LOCAL(0)]
        jmp .collisions.while
    .collisions.while.end:

    mov eax, [LOCAL(0)]
    cmp ax, [collisions.count]
    jne .found

    xor ecx, ecx
    mov cx, [collisions.count]
    shl ecx, 2
    mov dword [collisions.hashes + ecx], -1
    inc word [collisions.count]

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