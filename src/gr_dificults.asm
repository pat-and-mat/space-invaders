%include "video.inc"

section .data

global piece.gr.count
piece.gr.count dd 184
global piece.gr
piece.gr dw \
32,\
 95,\
 95,\
 95,\
 32,\
 95,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 95,\
 95,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 95,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 124,\
 32,\
 95,\
 32,\
 40,\
 95,\
 41,\
 95,\
 95,\
 95,\
 32,\
 95,\
 95,\
 32,\
 95,\
 95,\
 95,\
 32,\
 32,\
 32,\
 95,\
 95,\
 95,\
 32,\
 47,\
 32,\
 95,\
 124,\
 32,\
 32,\
 95,\
 95,\
 32,\
 95,\
 95,\
 32,\
 95,\
 124,\
 32,\
 124,\
 95,\
 95,\
 95,\
 95,\
 95,\
 32,\
 124,\
 32,\
 32,\
 95,\
 47,\
 32,\
 47,\
 32,\
 45,\
 95,\
 41,\
 32,\
 95,\
 47,\
 32,\
 45,\
 95,\
 41,\
 32,\
 47,\
 32,\
 95,\
 32,\
 92,\
 32,\
 32,\
 95,\
 124,\
 32,\
 47,\
 32,\
 95,\
 47,\
 32,\
 95,\
 96,\
 32,\
 124,\
 32,\
 47,\
 32,\
 47,\
 32,\
 45,\
 95,\
 41,\
 124,\
 95,\
 124,\
 32,\
 124,\
 95,\
 92,\
 95,\
 95,\
 95,\
 92,\
 95,\
 95,\
 92,\
 95,\
 95,\
 95,\
 124,\
 32,\
 92,\
 95,\
 95,\
 95,\
 47,\
 95,\
 124,\
 32,\
 32,\
 32,\
 92,\
 95,\
 95,\
 92,\
 95,\
 95,\
 44,\
 95,\
 124,\
 95,\
 92,\
 95,\
 92,\
 95,\
 95,\
 95,\
 124,\
 
global piece.gr.rows
piece.gr.rows dw \
0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 
global piece.gr.cols
piece.gr.cols dw \
0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 28,\
 29,\
 30,\
 31,\
 32,\
 33,\
 34,\
 35,\
 36,\
 37,\
 38,\
 39,\
 40,\
 41,\
 42,\
 43,\
 44,\
 45,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 28,\
 29,\
 30,\
 31,\
 32,\
 33,\
 34,\
 35,\
 36,\
 37,\
 38,\
 39,\
 40,\
 41,\
 42,\
 43,\
 44,\
 45,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 28,\
 29,\
 30,\
 31,\
 32,\
 33,\
 34,\
 35,\
 36,\
 37,\
 38,\
 39,\
 40,\
 41,\
 42,\
 43,\
 44,\
 45,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 28,\
 29,\
 30,\
 31,\
 32,\
 33,\
 34,\
 35,\
 36,\
 37,\
 38,\
 39,\
 40,\
 41,\
 42,\
 43,\
 44,\
 45,\
 
;------------------------------------------------------------------------------------------------

global cake.gr.count
cake.gr.count dd 68
global cake.gr
cake.gr dw \
32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 95,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 95,\
 95,\
 32,\
 95,\
 95,\
 32,\
 95,\
 124,\
 32,\
 124,\
 95,\
 95,\
 95,\
 95,\
 95,\
 32,\
 47,\
 32,\
 95,\
 47,\
 32,\
 95,\
 96,\
 32,\
 124,\
 32,\
 47,\
 32,\
 47,\
 32,\
 45,\
 95,\
 41,\
 92,\
 95,\
 95,\
 92,\
 95,\
 95,\
 44,\
 95,\
 124,\
 95,\
 92,\
 95,\
 92,\
 95,\
 95,\
 95,\
 124,\
 
global cake.gr.rows
cake.gr.rows dw \
0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 
global cake.gr.cols
cake.gr.cols dw \
0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 
;------------------------------------------------------------------------------------------------

global poker.gr.count
poker.gr.count dd 156
global poker.gr
poker.gr dw \
32,\
 95,\
 95,\
 95,\
 32,\
 32,\
 32,\
 32,\
 32,\
 95,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 95,\
 95,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 124,\
 32,\
 95,\
 32,\
 92,\
 95,\
 95,\
 95,\
 124,\
 32,\
 124,\
 95,\
 95,\
 95,\
 95,\
 95,\
 32,\
 95,\
 32,\
 95,\
 32,\
 32,\
 32,\
 47,\
 32,\
 95,\
 124,\
 95,\
 95,\
 32,\
 95,\
 32,\
 95,\
 95,\
 32,\
 95,\
 95,\
 95,\
 32,\
 124,\
 32,\
 32,\
 95,\
 47,\
 32,\
 95,\
 32,\
 92,\
 32,\
 47,\
 32,\
 47,\
 32,\
 45,\
 95,\
 41,\
 32,\
 39,\
 95,\
 124,\
 32,\
 124,\
 32,\
 32,\
 95,\
 47,\
 32,\
 95,\
 96,\
 32,\
 47,\
 32,\
 95,\
 47,\
 32,\
 45,\
 95,\
 41,\
 124,\
 95,\
 124,\
 32,\
 92,\
 95,\
 95,\
 95,\
 47,\
 95,\
 92,\
 95,\
 92,\
 95,\
 95,\
 95,\
 124,\
 95,\
 124,\
 32,\
 32,\
 32,\
 124,\
 95,\
 124,\
 32,\
 92,\
 95,\
 95,\
 44,\
 95,\
 92,\
 95,\
 95,\
 92,\
 95,\
 95,\
 95,\
 124,\
 
global poker.gr.rows
poker.gr.rows dw \
0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 
global poker.gr.cols
poker.gr.cols dw \
0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 28,\
 29,\
 30,\
 31,\
 32,\
 33,\
 34,\
 35,\
 36,\
 37,\
 38,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 28,\
 29,\
 30,\
 31,\
 32,\
 33,\
 34,\
 35,\
 36,\
 37,\
 38,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 28,\
 29,\
 30,\
 31,\
 32,\
 33,\
 34,\
 35,\
 36,\
 37,\
 38,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 28,\
 29,\
 30,\
 31,\
 32,\
 33,\
 34,\
 35,\
 36,\
 37,\
 38,\
 
;--------------------------------------------------------------------------------------------------

global insane.gr.count
insane.gr.count dd 112
global insane.gr
insane.gr dw \
32,\
 95,\
 95,\
 95,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 124,\
 95,\
 32,\
 95,\
 124,\
 95,\
 32,\
 95,\
 32,\
 32,\
 95,\
 95,\
 95,\
 32,\
 95,\
 95,\
 32,\
 95,\
 32,\
 95,\
 32,\
 95,\
 32,\
 32,\
 95,\
 95,\
 95,\
 32,\
 32,\
 124,\
 32,\
 124,\
 124,\
 32,\
 39,\
 32,\
 92,\
 40,\
 95,\
 45,\
 60,\
 47,\
 32,\
 95,\
 96,\
 32,\
 124,\
 32,\
 39,\
 32,\
 92,\
 47,\
 32,\
 45,\
 95,\
 41,\
 124,\
 95,\
 95,\
 95,\
 124,\
 95,\
 124,\
 124,\
 95,\
 47,\
 95,\
 95,\
 47,\
 92,\
 95,\
 95,\
 44,\
 95,\
 124,\
 95,\
 124,\
 124,\
 95,\
 92,\
 95,\
 95,\
 95,\
 124,\
 
global insane.gr.rows
insane.gr.rows dw \
0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 
global insane.gr.cols
insane.gr.cols dw \
0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 
;--------------------------------------------------------------------------------------------

global can_not.gr.count
can_not.gr.count dd 305
global can_not.gr
can_not.gr dw \
32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 95,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 95,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 95,\
 32,\
 32,\
 95,\
 32,\
 95,\
 95,\
 95,\
 32,\
 95,\
 32,\
 32,\
 95,\
 32,\
 32,\
 32,\
 95,\
 95,\
 32,\
 95,\
 95,\
 32,\
 95,\
 32,\
 95,\
 32,\
 95,\
 32,\
 32,\
 32,\
 32,\
 95,\
 32,\
 95,\
 32,\
 32,\
 95,\
 95,\
 95,\
 124,\
 32,\
 124,\
 95,\
 32,\
 32,\
 95,\
 95,\
 32,\
 95,\
 95,\
 32,\
 95,\
 40,\
 95,\
 41,\
 95,\
 32,\
 95,\
 32,\
 32,\
 124,\
 32,\
 124,\
 124,\
 32,\
 47,\
 32,\
 95,\
 32,\
 92,\
 32,\
 124,\
 124,\
 32,\
 124,\
 32,\
 47,\
 32,\
 95,\
 47,\
 32,\
 95,\
 96,\
 32,\
 124,\
 32,\
 39,\
 32,\
 92,\
 32,\
 32,\
 124,\
 32,\
 39,\
 32,\
 92,\
 47,\
 32,\
 95,\
 32,\
 92,\
 32,\
 32,\
 95,\
 124,\
 32,\
 92,\
 32,\
 86,\
 32,\
 32,\
 86,\
 32,\
 47,\
 32,\
 124,\
 32,\
 39,\
 32,\
 92,\
 32,\
 32,\
 92,\
 95,\
 44,\
 32,\
 92,\
 95,\
 95,\
 95,\
 47,\
 92,\
 95,\
 44,\
 95,\
 124,\
 32,\
 92,\
 95,\
 95,\
 92,\
 95,\
 95,\
 44,\
 95,\
 124,\
 95,\
 124,\
 124,\
 95,\
 124,\
 32,\
 124,\
 95,\
 124,\
 124,\
 95,\
 92,\
 95,\
 95,\
 95,\
 47,\
 92,\
 95,\
 95,\
 124,\
 32,\
 32,\
 92,\
 95,\
 47,\
 92,\
 95,\
 47,\
 124,\
 95,\
 124,\
 95,\
 124,\
 124,\
 95,\
 124,\
 32,\
 124,\
 95,\
 95,\
 47,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 32,\
 
global can_not.gr.rows
can_not.gr.rows dw \
0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 4,\
 
global can_not.gr.cols
can_not.gr.cols dw \
0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 28,\
 29,\
 30,\
 31,\
 32,\
 33,\
 34,\
 35,\
 36,\
 37,\
 38,\
 39,\
 40,\
 41,\
 42,\
 43,\
 44,\
 45,\
 46,\
 47,\
 48,\
 49,\
 50,\
 51,\
 52,\
 53,\
 54,\
 55,\
 56,\
 57,\
 58,\
 59,\
 60,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 28,\
 29,\
 30,\
 31,\
 32,\
 33,\
 34,\
 35,\
 36,\
 37,\
 38,\
 39,\
 40,\
 41,\
 42,\
 43,\
 44,\
 45,\
 46,\
 47,\
 48,\
 49,\
 50,\
 51,\
 52,\
 53,\
 54,\
 55,\
 56,\
 57,\
 58,\
 59,\
 60,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 28,\
 29,\
 30,\
 31,\
 32,\
 33,\
 34,\
 35,\
 36,\
 37,\
 38,\
 39,\
 40,\
 41,\
 42,\
 43,\
 44,\
 45,\
 46,\
 47,\
 48,\
 49,\
 50,\
 51,\
 52,\
 53,\
 54,\
 55,\
 56,\
 57,\
 58,\
 59,\
 60,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 28,\
 29,\
 30,\
 31,\
 32,\
 33,\
 34,\
 35,\
 36,\
 37,\
 38,\
 39,\
 40,\
 41,\
 42,\
 43,\
 44,\
 45,\
 46,\
 47,\
 48,\
 49,\
 50,\
 51,\
 52,\
 53,\
 54,\
 55,\
 56,\
 57,\
 58,\
 59,\
 60,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 9,\
 10,\
 11,\
 12,\
 13,\
 14,\
 15,\
 16,\
 17,\
 18,\
 19,\
 20,\
 21,\
 22,\
 23,\
 24,\
 25,\
 26,\
 27,\
 28,\
 29,\
 30,\
 31,\
 32,\
 33,\
 34,\
 35,\
 36,\
 37,\
 38,\
 39,\
 40,\
 41,\
 42,\
 43,\
 44,\
 45,\
 46,\
 47,\
 48,\
 49,\
 50,\
 51,\
 52,\
 53,\
 54,\
 55,\
 56,\
 57,\
 58,\
 59,\
 60,\
 
;------------------------------------------------------------------------------------------------

global p1.gr.count
p1.gr.count dd 32
global p1.gr
p1.gr dw \
32,\
 95,\
 95,\
 95,\
 32,\
 32,\
 95,\
 32,\
 124,\
 32,\
 95,\
 32,\
 92,\
 47,\
 32,\
 124,\
 124,\
 32,\
 32,\
 95,\
 47,\
 124,\
 32,\
 124,\
 124,\
 95,\
 124,\
 32,\
 32,\
 124,\
 95,\
 124,\
 
global p1.gr.rows
p1.gr.rows dw \
0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 
global p1.gr.cols
p1.gr.cols dw \
0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 
 ;---------------------------------------------------------------------------------------------

global p2.gr.count
p2.gr.count dd 36
global p2.gr
p2.gr dw \
32,\
 95,\
 95,\
 95,\
 32,\
 95,\
 95,\
 95,\
 32,\
 124,\
 32,\
 95,\
 32,\
 92,\
 95,\
 32,\
 32,\
 41,\
 124,\
 32,\
 32,\
 95,\
 47,\
 47,\
 32,\
 47,\
 32,\
 124,\
 95,\
 124,\
 32,\
 47,\
 95,\
 95,\
 95,\
 124,\
 
global p2.gr.rows
p2.gr.rows dw \
0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 0,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 1,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 2,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 3,\
 
global p2.gr.cols
p2.gr.cols dw \
0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 0,\
 1,\
 2,\
 3,\
 4,\
 5,\
 6,\
 7,\
 8,\
 
