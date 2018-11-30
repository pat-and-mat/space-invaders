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

debug_info times 80 dw 0
debug_info.count dw 0

section .bss

map resd COLS * ROWS

section .text

extern array.shiftr
extern array.index_of

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

; debug
extern video.set_rect

; update()
; It is here where all the actions related to this object will be taking place
engine.update:
    FUNC.START
    CLEAR_MAP 0
    mov dword [map + (12*80 + 39)*4], 6 << 16 | 4
    CALL player.update, map
    CALL weapons.update, map
    ; CALL enemy.update, map
    FUNC.END

; paint()
; Puts the object's graphics in the screen
engine.paint:
    FUNC.START
    CALL video.clear, BG.BLACK
    call player.paint
    call weapons.paint
    ; call enemy.paint
    call video.refresh
    FUNC.END

; ******************************************************************************************
; * Collisions                                                                             *
; ******************************************************************************************

; collision()
; It is here where collisions will be handled
engine.collision:
    FUNC.START
    mov ax, [collisions.count]
    add ax, 48
    or ax, FG.RED
    mov [debug_info + 79*2], ax
    mov word [collisions.count], 0
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
    call engine.debug
    FUNC.END

engine.debug:
    FUNC.START
    CALL video.set_rect, debug_info, 24, 0, 1, 80
    CALL video.print, BG.RED, 12, 39
    call video.refresh

    mov edi, debug_info
    mov eax, 0
    mov ecx, 80
    cld
    rep stosw

    FUNC.END