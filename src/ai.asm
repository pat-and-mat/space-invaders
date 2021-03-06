%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"
%include "sound.inc"
%include "utils.inc"
%include "hash.inc"

extern video.print
extern weapons.shoot
extern engine.add_collision
extern delay
extern play_shoot
extern enemy_blue.take_damage
extern enemy_red.take_damage
extern enemy_yellow.take_damage
extern weapons.get_dir
extern can_move

%define SHIP.COORDS 5
%define AI.FEAT 10
%define AI.THRESHOLD 10

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

%define ROW.BOTTOM 0
%define COL.RIGHT 4

; Data section is meant to hold constant values, do not modify
section .data

graphics dd '/'|FG.GREEN|BG.BLACK,\
            '-'|FG.GREEN|BG.BLACK,\
            '^'|FG.GREEN|BG.BLACK,\
            '-'|FG.GREEN|BG.BLACK,\
            '\'|FG.GREEN|BG.BLACK,\
 
            
rows dd 0, 0, 0, 0, 0
cols dd 0, 1, 2, 3, 4

weapon.row dd 0
weapon.col dd 2

; 0-enemyl 1-enemyr 2-dangerl 3-dangerr 4-dangerf 5-dangerb 6-Killable 7-move_cont 8-shots_cont 9-1
;                    0   1    2    3   4   5   6   7   8   9
ai.shoot.weights dd  0,  0,   0,   0,  0,  0, 30, 10, -15, 10
ai.right.weights dd  0,  1,  12, -20, 20,  1, -1, -5,  7,  0
ai.left.weights  dd  1,  0, -20,  12, 20,  1, -1, -5,  7,  0
ai.up.weights    dd  0,  0,   5,   5, -5,  4, -1, -5,  7,  0
ai.down.weights  dd  0,  0,   5,   5,  1, -5, -1, -5,  7,  0

section .bss

global ai.lives
ai.lives resw 1

row.offset resd 1
col.offset resd 1

ai.features resd AI.FEAT
ai.feat.shots_cont resd 1
ai.feat.move_cont resd 1

; 1-up 2-down 3-left 4-right 5-shot
ai.predictions resd 5

ai.timer resd 2

section .text

; init(word ai.lives, dword r.offset, dword c.offset)
; Initialize ai
global ai.init
ai.init:
    FUNC.START
    ;filling local vars of ai
    mov ax, [PARAM(0)]
    mov [ai.lives], ax

    mov dword [ai.feat.move_cont], 0
    mov dword [ai.feat.shots_cont], 0
    
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

    cmp word [ai.lives], 0
    je .update.end

    CALL delay, ai.timer, 100
    cmp eax, 0
    je .update.map

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

    jmp .update.map

    .update.move.up:
        cmp dword [row.offset], 1
        je .update.map
        sub dword [row.offset], 1

        inc dword [ai.feat.move_cont]
        mov dword [ai.feat.shots_cont], 0

        jmp .update.map

    .update.move.down:
        cmp dword [row.offset], 24
        je .update.map
        add dword [row.offset], 1

        inc dword [ai.feat.move_cont]
        mov dword [ai.feat.shots_cont], 0

        jmp .update.map

    .update.move.left:
        cmp dword [col.offset], 0
        je .update.map
        sub dword [col.offset], 1

        inc dword [ai.feat.move_cont]
        mov dword [ai.feat.shots_cont], 0

        jmp .update.map

    .update.move.right:
        cmp dword [col.offset], 75
        je .update.map    
        add dword [col.offset], 1

        inc dword [ai.feat.move_cont]
        mov dword [ai.feat.shots_cont], 0

        jmp .update.map

    .update.shoot:
        ;calculate the position of the shot
        mov eax, [weapon.row]
        add eax, [row.offset]
        sub eax, 1
        mov [LOCAL(0)], eax

        mov eax, [weapon.col]
        add eax, [col.offset]
        mov [LOCAL(1)], eax

        CALL weapons.shoot, [LOCAL(0)], [LOCAL(1)], 1

        inc dword [ai.feat.shots_cont]
        mov dword [ai.feat.move_cont], 0

        jmp .update.map 

    .update.map:
        CALL ai.put_in_map, [PARAM(0)]   
    .update.end:

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

; collision(dword HASH.other, dword inst_other)
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

    cmp word [ai.lives], 0
    je paint.end

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
    paint.end:
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
        mov word [ai.lives], 0
        jmp end

    end:
        xor eax, eax
        mov ax, [ai.lives]
    FUNC.END

; ai.comp_next(dword *map)
; comps the next action of the ai
ai.comp_next:
    FUNC.START
    RESERVE(3) ; i, pred_ind, pred_val

    CALL ai.comp_feats, [PARAM(0)]
    call ai.comp_preds
    CALL ai.rm_impossible, [PARAM(0)]
    
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

; ai.rm_impossible(dword *map)
ai.rm_impossible:
    FUNC.START
    CALL can_move, [PARAM(0)], [row.offset], [col.offset], rows, cols, SHIP.COORDS, 0, 1, 0, 0, HASH.AI << 16
    cmp eax, 0
    je .rm_impossible.move_up

    CALL can_move, [PARAM(0)], [row.offset], [col.offset], rows, cols, SHIP.COORDS, 1, 0, 0, 0, HASH.AI << 16
    cmp eax, 0
    je .rm_impossible.move_down

    CALL can_move, [PARAM(0)], [row.offset], [col.offset], rows, cols, SHIP.COORDS, 0, 0, 1, 0, HASH.AI << 16
    cmp eax, 0
    je .rm_impossible.move_right

    CALL can_move, [PARAM(0)], [row.offset], [col.offset], rows, cols, SHIP.COORDS, 0, 0, 0, 1, HASH.AI << 16
    cmp eax, 0
    je .rm_impossible.move_left
    
    jmp .rm_impossible.end
    
    .rm_impossible.move_up:
        mov dword [ai.predictions + 0*4], 0
        jmp .rm_impossible.end
    
    .rm_impossible.move_down:
        mov dword [ai.predictions + 1*4], 0
        jmp .rm_impossible.end
    
    .rm_impossible.move_left:
        mov dword [ai.predictions + 2*4], 0
        jmp .rm_impossible.end
    
    .rm_impossible.move_right:
        mov dword [ai.predictions + 3*4], 0
        jmp .rm_impossible.end

    .rm_impossible.end:
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
        imul dword [edx + ecx]
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
    RESERVE(4)  ; i, j, hash, inst

    mov edi, ai.features
    mov ecx, AI.FEAT
    mov eax, 0
    cld
    rep stosd

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
            add eax, [PARAM(0)]
            
            mov eax, [eax]

            xor edx, edx
            mov dx, ax
            mov [LOCAL(3)], edx

            shr eax, 16
            mov [LOCAL(2)], eax            

            CALL ai.is_enemy_left, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)], [LOCAL(3)]
            add [ai.features + 0*4], eax       

            CALL ai.is_enemy_right, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)], [LOCAL(3)]
            add [ai.features + 1*4], eax

            CALL ai.is_danger_left, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)], [LOCAL(3)]
            add [ai.features + 2*4], eax

            CALL ai.is_danger_right, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)], [LOCAL(3)]
            add [ai.features + 3*4], eax

            CALL ai.is_danger_forward, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)], [LOCAL(3)]
            add [ai.features + 4*4], eax

            CALL ai.is_danger_backward, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)], [LOCAL(3)]
            add [ai.features + 5*4], eax

            CALL ai.is_killable, [LOCAL(0)], [LOCAL(1)], [LOCAL(2)]
            add [ai.features + 6*4], eax            

            inc dword [LOCAL(1)]
            jmp .comp_feats.while_j
        .comp_feats.while_j.end:

        inc dword [LOCAL(0)]
        jmp .comp_feats.while_i
    .comp_feats.while_i.end:

    mov eax, [ai.feat.move_cont]
    mov [ai.features + 7*4], eax
    
    mov eax, [ai.feat.shots_cont]
    mov [ai.features + 8*4], eax

    mov dword [ai.features + 9*4], 1

    FUNC.END

; ai.comp_sigmoid(dword x)
ai.comp_sigmoid:
    FUNC.START
    mov eax, [PARAM(0)]
    FUNC.END

; ai.is_***(dword i, dword j, dword hash, dword inst)
; Returns value for given condition

ai.is_enemy_left:
    FUNC.START
    mov eax, [col.offset]
    add eax, 2
    cmp dword [PARAM(1)], eax
    jge enemy_left.false
    mov eax, [row.offset]
    cmp dword [PARAM(0)], eax
    jge enemy_left.false

    cmp dword [PARAM(2)], HASH.ENEMY_BLUE
    je enemy_left.true
    cmp dword [PARAM(2)], HASH.ENEMY_RED
    je enemy_left.true
    cmp dword [PARAM(2)], HASH.ENEMY_YELLOW
    je enemy_left.true
    cmp dword [PARAM(2)], HASH.ENEMY_BOSS
    je enemy_left.true
    
    jmp enemy_left.false


    enemy_left.true:
    mov eax, 1
    jmp enemy_left.end
    
    enemy_left.false:
    mov eax, 0

    enemy_left.end:
    FUNC.END

ai.is_enemy_right:
    FUNC.START
    mov eax, [col.offset]
    add eax, 2
    cmp dword [PARAM(1)], eax
    jle enemy_right.false
    mov eax, [row.offset]
    cmp dword [PARAM(0)], eax
    jge enemy_right.false

    cmp dword [PARAM(2)], HASH.ENEMY_BLUE
    je enemy_right.true
    cmp dword [PARAM(2)], HASH.ENEMY_RED
    je enemy_right.true
    cmp dword [PARAM(2)], HASH.ENEMY_YELLOW
    je enemy_right.true
    cmp dword [PARAM(2)], HASH.ENEMY_BOSS
    je enemy_right.true
   
    jmp enemy_right.false

    enemy_right.true:
    mov eax, 1
    jmp enemy_right.end
    
    enemy_right.false:
    mov eax, 0

    enemy_right.end:
    FUNC.END

ai.is_danger_left:
    FUNC.START
    RESERVE(1)
    sub dword [col.offset], 2
    CALL ai.is_danger, [PARAM(0)], [PARAM(1)], [PARAM(2)], [PARAM(3)], 4
    mov [LOCAL(0)], eax
    CALL ai.is_danger, [PARAM(0)], [PARAM(1)], [PARAM(2)], [PARAM(3)], 2
    add [LOCAL(0)], eax
    add dword [col.offset], 2
    mov eax, [LOCAL(0)]
    FUNC.END

ai.is_danger_right:
    FUNC.START
    RESERVE(1)
    add dword [col.offset], 2
    CALL ai.is_danger, [PARAM(0)], [PARAM(1)], [PARAM(2)], [PARAM(3)], 4
    mov [LOCAL(0)], eax
    CALL ai.is_danger, [PARAM(0)], [PARAM(1)], [PARAM(2)], [PARAM(3)], 2
    add [LOCAL(0)], eax
    sub dword [col.offset], 2
    mov eax, [LOCAL(0)]
    FUNC.END

ai.is_danger_forward:
    FUNC.START
    RESERVE(1)
    dec dword [row.offset]
    CALL ai.is_danger, [PARAM(0)], [PARAM(1)], [PARAM(2)], [PARAM(3)], 4
    mov [LOCAL(0)], eax
    CALL ai.is_danger, [PARAM(0)], [PARAM(1)], [PARAM(2)], [PARAM(3)], 2
    add [LOCAL(0)], eax
    inc dword [row.offset]
    mov eax, [LOCAL(0)]
    FUNC.END

ai.is_danger_backward:
    FUNC.START
    RESERVE(1)
    inc dword [row.offset]
    CALL ai.is_danger, [PARAM(0)], [PARAM(1)], [PARAM(2)], [PARAM(3)], 4
    mov [LOCAL(0)], eax
    CALL ai.is_danger, [PARAM(0)], [PARAM(1)], [PARAM(2)], [PARAM(3)], 2
    add [LOCAL(0)], eax
    dec dword [row.offset]
    mov eax, [LOCAL(0)]
    FUNC.END

ai.is_killable:
    FUNC.START
    xor eax, eax
    
    .killable.check_hash:
        cmp dword [PARAM(2)], HASH.ENEMY_BLUE
        jne .killable.end
        jmp .killable.check_row

        cmp dword [PARAM(2)], HASH.ENEMY_RED
        jne .killable.end
        jmp .killable.check_row

        cmp dword [PARAM(2)], HASH.ENEMY_YELLOW
        jne .killable.end
        jmp .killable.check_row

        cmp dword [PARAM(2)], HASH.ENEMY_BOSS
        jne .killable.end
        jmp .killable.check_row

        cmp dword [PARAM(2)], HASH.ENEMY_METEORO
        jne .killable.end
        jmp .killable.check_row

    .killable.check_row:
        mov edx, [row.offset]

        cmp [PARAM(0)], edx
        jnl .killable.end

    .killable.check_col:
        mov edx, [col.offset]

        cmp [PARAM(1)], edx
        jng .killable.end

        mov edx, [col.offset]
        add edx, COL.RIGHT

        cmp [PARAM(1)], edx
        jnl .killable.end
    
    mov eax, 1

    .killable.end:
    FUNC.END

; ai.is_***(dword i, dword j, dword hash, dword inst, dword dist)
ai.is_danger:
    FUNC.START

    mov eax, [row.offset]
    add eax, ROW.BOTTOM
    cmp [PARAM(0)], eax
    jg is_danger.false

    mov eax, [col.offset]
    cmp [PARAM(1)], eax
    jl is_danger.false

    mov eax, [row.offset]
    sub eax, [PARAM(4)]
    cmp [PARAM(0)], eax
    jl is_danger.false

    mov eax, [col.offset]
    add eax, COL.RIGHT
    cmp [PARAM(1)], eax
    jg is_danger.false

    cmp dword [PARAM(2)], HASH.ENEMY_BLUE
    je is_danger.true1
    cmp dword [PARAM(2)], HASH.ENEMY_RED
    je is_danger.true1
    cmp dword [PARAM(2)], HASH.ENEMY_YELLOW
    je is_danger.true1
    cmp dword [PARAM(2)], HASH.ENEMY_BOSS
    je is_danger.true1
    cmp dword [PARAM(2)], HASH.ENEMY_METEORO
    je is_danger.true1

    cmp dword [PARAM(2)], HASH.SHOT
    jne is_danger.false

    CALL weapons.get_dir, [PARAM(3)]

    cmp eax, 0
    je is_danger.true5

    cmp eax, 5
    je is_danger.true5

    cmp eax, 7
    je is_danger.true5

    jmp is_danger.false

    is_danger.true1:
    mov eax, 1
    jmp is_danger.end

    is_danger.true5:
    mov eax, 8
    jmp is_danger.end

    is_danger.false:
    mov eax, 0

    is_danger.end:
    FUNC.END