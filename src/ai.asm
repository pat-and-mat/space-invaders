%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"
%include "sound.inc"
%include "utils.inc"
%include "hash.inc"

extern engine.debug
extern video.print
extern weapons.shoot
extern engine.add_collision
extern input
extern beep.on
extern beep.set
extern beep.off
extern delay
extern play_shoot
extern play_ai_die
extern menu.lose
extern sound_ai_die.update
extern sound.timer
extern enemy_blue.take_damage
extern enemy_red.take_damage
extern enemy_yellow.take_damage
extern debug_info

%define SHIP.COORDS 5
%define AI.FEAT 8
%define AI.THRESHOLD 50

%macro SHIP.ROW 1
    xor eax, eax
    mov ax, [row.offset]
    add ax, %1
%endmacro

%macro SHIP.COL 1
    xor eax, eax
    mov ax, [col.offset]
    add ax, %1
%endmacro

; Data section is meant to hold constant values, do not modify
section .data

graphics dd '/'|FG.GREEN|BG.BLACK,\
            '-'|FG.GREEN|BG.BLACK,\
            '^'|FG.GREEN|BG.BLACK,\
            '-'|FG.GREEN|BG.BLACK,\
            '\'|FG.GREEN|BG.BLACK,\
 
            
rows dd 0, 0, 0, 0, 0
cols dd 0, 1, 2, 3, 4

col.left dd 0
col.right dd 3

weapon.row dd 0
weapon.col dd 2

ai.shoot.weights dd 0, 0, 0, 0, 0, 0, 0, 0
ai.right.weights dd 0, 0, 0, 0, 0, 0, 0, 0
ai.left.weights dd 0, 0, 0, 0, 0, 0, 0, 0
ai.up.weights dd 0, 0, 0, 0, 0, 0, 0, 0
ai.down.weights dd 0, 0, 0, 0, 0, 0, 0, 0

section .bss

global ai.lives
ai.lives resw 1

row.offset resd 1
col.offset resd 1

; 0-left_enemies 1-right_enemies 2-left_danger 3-right_danger 4-forward_danger 5-backward_danger 6-Killable
ai.features resd AI.FEAT
ai.predictions resd 5

ai.timer resd 1

section .text

; init(word ai.lives, dword r.offset, dword c.offset)
; Initialize ai
global ai.init
ai.init:
    FUNC.START
    ;filling local vars of ai
    mov ax, [PARAM(0)]
    mov [ai.lives], ax
    
    mov eax, [PARAM(1)]
    mov [row.offset], eax
    
    mov eax, [PARAM(2)]
    mov [col.offset], eax

    FUNC.END

; update(dword *map)
; It is here where all the actions related to this object will be taking place
global ai.update
ai.update:
    FUNC.START
    RESERVE(2)

    CALL ai.comp_next, [PARAM(0)]

    cmp eax, 1
    je .update.move.up

    cmp eax, 2
    je .update.move.down

    cmp eax, 3
    je .update.move.left

    cmp eax, 4
    je .update.move.right

    cmp eax, 5
    je .update.shoot

    jmp .update.end

    .update.move.up:
        cmp dword [row.offset], 1
        je .update.end
        sub dword [row.offset], 1
        jmp .update.end

    .update.move.down:
        cmp dword [row.offset], 24
        je .update.end
        add dword [row.offset], 1
        jmp .update.end

    .update.move.left:
        cmp dword [col.offset], 0
        je .update.end
        sub dword [col.offset], 1
        jmp .update.end

    .update.move.right:
        cmp dword [col.offset], 75
        je .update.end    
        add dword [col.offset], 1
        jmp .update.end

    .update.shoot:
        CALL delay, ai.timer, 250
        cmp eax, 0
        je .update.end

        ;shoot sound
        call play_shoot

        ;calculate the position of the shot
        mov eax, [weapon.row]
        add eax, [row.offset]
        sub eax, 1
        mov [LOCAL(0)], eax

        mov eax, [weapon.col]
        add eax, [col.offset]
        mov [LOCAL(1)], eax

        CALL weapons.shoot, [LOCAL(0)], [LOCAL(1)], 1
        
        jmp .update.end 

    .update.end:
        CALL ai.put_in_map, [PARAM(0)]   
    FUNC.END

; ai.put_in_map(dword *map)
ai.put_in_map:
    FUNC.START
    RESERVE(4) ; i, row, col, offset

    mov dword [LOCAL(0)], 0
    .map.while:
        cmp dword [LOCAL(0)], SHIP.COORDS
        je .map.while.end

        mov ecx, [LOCAL(0)]
        shl ecx, 2

        mov eax, [row.offset]
        add eax, [rows + ecx]
        mov [LOCAL(1)], eax

        mov eax, [col.offset]
        add eax, [cols + ecx]
        mov [LOCAL(2)], eax

        OFFSET [LOCAL(1)], [LOCAL(2)]

        mov [LOCAL(3)], eax
        shl eax, 2
        add eax, [PARAM(0)]
        
        cmp dword [eax], 0
        je .map.while.cont

        ; Collision
        CALL engine.add_collision, HASH.AI << 16, [eax]

        .map.while.cont:
            mov eax, [LOCAL(3)]
            shl eax, 2
            add eax, [PARAM(0)]

            mov dword [eax], HASH.AI << 16
            inc dword [LOCAL(0)]
            jmp .map.while
    .map.while.end:
    FUNC.END

; collision(dword hash_other, dword inst_other)
; It is here where collisions will be handled
global ai.collision
ai.collision:
    FUNC.START
    cmp dword [PARAM(0)], HASH.ENEMY_BLUE
    je crash_blue
    cmp dword [PARAM(0)], HASH.ENEMY_RED
    je crash_red
    cmp dword [PARAM(0)], HASH.ENEMY_YELLOW
    je crash_yellow

    jmp crashed

    crash_blue:
    CALL enemy_blue.take_damage, 1, [PARAM(1)]
    jmp crashed

    crash_red:
    CALL enemy_red.take_damage, 1, [PARAM(1)]
    jmp crashed

    crash_yellow:
    CALL enemy_yellow.take_damage, 1, [PARAM(1)]
    jmp crashed

    crashed:
    FUNC.END

; paint()
; Puts the object's graphics in the screen
global ai.paint
ai.paint:
    FUNC.START
    RESERVE(2)

    mov ecx, 0    
    while:
        cmp ecx, SHIP.COORDS * 4
        jnl while.end
        
        mov eax, [row.offset]
        add eax, [rows + ecx]
        mov [LOCAL(0)], eax

        mov eax, [col.offset]
        add eax, [cols + ecx]
        mov [LOCAL(1)], eax

        push ecx
        CALL video.print, [graphics + ecx], [LOCAL(0)], [LOCAL(1)]
        pop ecx

        add ecx, 4
        jmp while
        while.end:
        FUNC.END

; ai.take_damage(dword damage)
; Takes ai.lives away from ai
; returns 1 if ai remains alive after damage, 0 otherwise
global ai.take_damage
ai.take_damage:
    FUNC.START
    
    mov eax, [PARAM(0)]
    cmp [ai.lives], ax
    jng .destroyed
    sub [ai.lives], ax
    jmp end

    .destroyed:
        mov eax, 0
        mov word [ai.lives], 0
        jmp end

    end:
        FUNC.END

; ai.comp_next(dword *map)
; comps the next action of the ai
ai.comp_next:
    FUNC.START
    RESERVE(3) ; i, pred_ind, pred_val

    CALL ai.comp_feats, [PARAM(0)]
    call ai.comp_preds
    
    mov dword [LOCAL(1)], 0
    mov dword [LOCAL(2)], 0
    mov dword [LOCAL(0)], 0
    .comp_next.while:

        mov ecx, [LOCAL(0)]
        cmp ecx, 5
        jae .comp_next.while.end

        shl ecx, 2

        mov eax, [ai.predictions + ecx]

        cmp eax, AI.THRESHOLD
        jng .comp_next.while.cont

        cmp eax, [LOCAL(2)]
        jng .comp_next.while.cont

        mov ecx, [LOCAL(0)]
        inc ecx
        mov [LOCAL(1)], ecx
        mov [LOCAL(2)], eax

    .comp_next.while.cont:
        inc dword [LOCAL(0)]
        jmp .comp_next.while

    .comp_next.while.end:
    
    mov eax, [LOCAL(1)]
    
    FUNC.END

; ai.comp_preds(dword *weights)
ai.comp_preds:
    FUNC.START
    CALL ai.comp_pred, ai.up.weights
    mov [ai.predictions + 0*4], eax
    CALL ai.comp_pred, ai.down.weights
    mov [ai.predictions + 1*4], eax
    CALL ai.comp_pred, ai.left.weights
    mov [ai.predictions + 2*4], eax
    CALL ai.comp_pred, ai.right.weights
    mov [ai.predictions + 3*4], eax
    CALL ai.comp_pred, ai.shoot.weights
    mov [ai.predictions + 4*4], eax
    FUNC.END


; ai.comp_pred(dword *weights)
ai.comp_pred:
    FUNC.START
    RESERVE(2) ; i, sum

    mov dword [LOCAL(1)], 0
    mov dword [LOCAL(0)], 0

    .comp_preds.while:
        mov ecx, [LOCAL(0)]
        cmp ecx, AI.FEAT
        je .comp_preds.while.end

        shl ecx, 2
        mov eax, [ai.features + ecx]
        mov edx, [PARAM(0)]
        mul dword [edx + ecx]
        add [LOCAL(1)], eax

        inc dword [LOCAL(0)]
        jmp .comp_preds.while
    .comp_preds.while.end:

    CALL ai.comp_sigmoid, [LOCAL(1)]

    FUNC.END

; ai.comp_feats(dword *map)
; comps feature vect
ai.comp_feats:
    FUNC.START
    RESERVE(3)  ; i, j, hash

    mov dword [LOCAL(0)], 0
    .comp_feats.while_i:
        cmp dword [LOCAL(0)], ROWS
        je .comp_feats.while_i.end

        mov dword [LOCAL(1)], 0
        .comp_feats.while_j:
            cmp dword [LOCAL(1)], COLS
            je .comp_feats.while_j.end

            OFFSET [LOCAL(0)], [LOCAL(1)]
            shl eax, 2
            
            mov eax, [eax]
            shr eax, 16
            mov [LOCAL(2)], eax

            CALL ai.is_enemy_left, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)]
            add [ai.features + 0*4], eax

            CALL ai.is_enemy_right, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)]
            add [ai.features + 1*4], eax

            CALL ai.is_danger_left, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)]
            add [ai.features + 2*4], eax

            CALL ai.is_danger_right, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)]
            add [ai.features + 3*4], eax

            CALL ai.is_danger_forward, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)]
            add [ai.features + 4*4], eax

            CALL ai.is_danger_backward, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)]
            add [ai.features + 5*4], eax

            CALL ai.is_killable, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)]
            add [ai.features + 6*4], eax

            inc dword [LOCAL(1)]
            jmp .comp_feats.while_j
        .comp_feats.while_j.end:

        inc dword [LOCAL(0)]
        jmp .comp_feats.while_i
    .comp_feats.while_i.end:

    mov dword [ai.features + (AI.FEAT - 1)*4], 1
    FUNC.END

; ai.comp_sigmoid(dword x)
ai.comp_sigmoid:
    FUNC.START
    mov eax, [PARAM(0)]
    FUNC.END

; ai.is_***(dword i, dword j, dword hash)
; Returns 1 if condition is met, 0 otherwise

ai.is_enemy_left:
    FUNC.START
    FUNC.END

ai.is_enemy_right:
    FUNC.START
    FUNC.END

ai.is_danger_left:
    FUNC.START
    FUNC.END

ai.is_danger_right:
    FUNC.START
    FUNC.END

ai.is_danger_forward:
    FUNC.START
    FUNC.END

ai.is_danger_backward:
    FUNC.START
    FUNC.END

ai.is_killable:
    FUNC.START
    FUNC.END