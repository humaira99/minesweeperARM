        B main

; Our board:
; 0, represents an empty space
; 1-8 represents the number of bombs around us
; 66 represents there is a bomb at this location
; No more than 8 bombs
        ALIGN
board   DEFW  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        ALIGN
boardMask
        DEFW -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
       
        ALIGN
seed    DEFW    0xC0FFEE
magic   DEFW    65539
mask    DEFW    0x7FFFFFFF
bomb    DEFW    66
four    DEFW    4
count   DEFW    0
countsq DEFW    0
zerow   DEFW    0
index   DEFW    0
cell    DEFW    0
roww    DEFW    0
column  DEFW    0
fs      DEFW    56
eight   DEFW    8
        ALIGN
mine    DEFB    "M",0
tspace  DEFB    "  ",0
ospace  DEFB    " ",0
line    DEFB    "\n",0
row     DEFB    "                                        \n",0
number  DEFB    "     1    2    3    4    5    6    7    8\n",0
star    DEFB    "*",0
error   DEFB    "Error: invalid input. Restart\n",0

prompt  DEFB "Enter square to reveal: ",0
remain  DEFB "\nThere are ",0
remain2 DEFB " squares remaining.\n",0
already DEFB "\nThat square has already been revealed...\n", 0
loseMsg DEFB "\nYou stepped on a mine, you lose!\n",0
winMsg  DEFB "\nYou successfully uncovered all the squares while avoiding all the mines...\n",0

        ALIGN
main    MOV R13, #0x10000

; Your main game code goes here
        ADRL R0, board 
        
        LDR R5, count
        
        BL generateBoard
        ADRL R0, board

loop    BL clearScreen    

        ADRL R0, board
        ADRL R1, boardMask
        BL printMaskedBoard             ; prints masked board

        ADRL R0, remain                 ;there are ... squares remaining
        SWI 3
        LDR R1, countsq
        LDR R3, fs
        SUB R0, R3, R1
        SWI 4
        ADRL R0, remain2
        SWI 3
        
        ADRL R0, board
        ADRL R1, boardMask
        BL boardSquareInput             ; enter cell no to reveal
        
        ADRL R0, boardMask      
        LDR R1, index
        LDR R0, [R0, R1]                
        CMP R0, #0                      ; if already 0 - go to already done
        BEQ done
        LDR R2, zerow
        ADRL R0, boardMask
        STR R2, [R0, R1]                ; puts 0 in to board mask

        LDR R1, countsq                 ; number of squares revealed goes up by 1
        ADD R1, R1, #1
        STR R1, countsq

        ADRL R0, board
        LDR R1, index
        LDR R0, [R0, R1]                ; checks if mine is in cell
        CMP R0, #66
        BGE dead                        ; dead

        LDR R1, countsq
        CMP R1, #56                     ; if all non mine squares reveled - won
        BEQ win
        BNE loop

done    ADRL R0, already                 ; this cell has already been revealed
        SWI 3
        ADRL R0, row
        SWI 3
        ADRL R0, row
        SWI 3
        ADRL R0, row
        SWI 3
        
        B loop                          ; loops 

dead    ADRL R0, loseMsg
        SWI 3
        SWI 2

win     ADRL R0, winMsg
        SWI 3
        SWI 2


; clearScreen : Clear the screen
; Input:  none
; Output: none
clearScreen
        STMFD R13!, {R0-R1, R14} 
        LDR R1, count
cs      MOV R0, #8
        SWI 0
        ADD R1, R1, #1
        CMP R1, #1000
        BEQ end
        B cs

end     LDMFD R13!, {R0-R1, PC} 
        MOV PC, R14; Insert your clear screen subroutine here

; boardSquareInput -- read board position from keyboard
; Input:  R0 ---> prompt string address
; Ouptut: R0 <--- index

boardSquareInput
        STMFD R13!, {R0-R4, R14}  
repeat
        ADRL R0, prompt
        SWI 3

        SWI 1
        SWI 0

        CMP R0, #64
        BLE wrong
        CMP R0, #73
        BGE checkk

        CMP R0, #64
        BGT caps

checkk  CMP R0, #105
        BGE wrong
        CMP R0, #96
        BLE wrong  
        CMP R0, #97
        BGE lower 

wrong   ADRL R0, error
        SWI 3
        B repeat
        
caps    SUB R0, R0, #65
        STR R0, roww
        B numberr

lower   SUB R0, R0, #97
        STR R0, roww
        B numberr

numberr SWI 1
        SWI 0

        CMP R0, #48
        BLE wrong

        CMP R0, #57
        BGE wrong

        CMP R0, #49
        BGE col

col     SUB R0, R0, #49
        STR R0, column
        SWI 1
        CMP R0, #10
        BEQ indexx

indexx  LDR R1, roww
        LDR R2, column  
        LDR R3, four
        LDR R4, eight

        MLA R0, R4, R1, R2          ; 8c+r        
        MUL R0, R0, R3                 ; index
        ;MOV R1, R0
        STR R0, index
        
        LDMFD R13!, {R0-R4, PC} 
        MOV PC, R14; Copy your readBoardPos subroutine here.


; printMaskedBoard -- print the board 
; Input: R0 <-- Address of board
;        R1 <-- Address of board Mask
printMaskedBoard
        STMFD R13!, {R0-R10, R14}  
        ADRL R6, mine                                ; Insert your implementation of printMaskedBoard here.
        ADRL R7, ospace
        ADRL R5, star
        
        MOV R2, R1 
        MOV R1, R0                    

        ADRL R8, number
        MOV R0, R8
        SWI 3

        ADRL R0, row
        SWI 3

        MOV R9, #65
        MOV R0, R9
        SWI 0

        ADRL R8, tspace
        MOV R0, R8
        SWI 3

        ADRL R8, tspace
        MOV R0, R8
        SWI 3

        LDR R3, [R2]
        LDR R0, [R1]
        B compp1

nextt   ADRL R8, tspace
        MOV R0, R8
        SWI 3

        ADD R4, R4, #4
        B checckk
    
checckk  CMP R4, #32 
        BEQ newlinee
        CMP R4, #64
        BEQ newlinee
        CMP R4, #96
        BEQ newlinee
        CMP R4, #128
        BEQ newlinee
        CMP R4, #160
        BEQ newlinee
        CMP R4, #192
        BEQ newlinee
        CMP R4, #224
        BEQ newlinee
        CMP R4, #256
        BEQ endd

        B secondd

secondd 
        ADRL R8, tspace
        MOV R0, R8
        SWI 3

        LDR R3, [R2, R4]
        LDR R0, [R1, R4]
        B compp1

newlinee 
        ADRL R0, line
        SWI 3

        ADRL R0, row
        SWI 3

        ADD R9, R9, #1

        MOV R0, R9
        SWI 0

        ADRL R8, tspace
        MOV R0, R8
        SWI 3

        B secondd

compp1  CMP R3, #0
        BNE astt
        CMP R0, #66
        BEQ Mm
        CMP R0, #0
        BEQ zerro
        SWI 4
        B nextt
        
Mm      CMP R3, #0
        BNE astt
        MOV R0, R6
        SWI 3
        B nextt

zerro   CMP R3, #0
        BNE astt
        MOV R0, R7
        SWI 3
        B nextt

astt    MOV R0, R5
        SWI 3
        B nextt

endd    LDMFD R13!, {R0-R10, PC}
        MOV PC,R14

; Insert your  implementation here

; generateBoard
; Input R0 -- array to generate board in
generateBoard
        STMFD R13!, {R0-R10, R14}  
gen     LDR R7, bomb
        LDR R10, four

        MUL R8, R8, R10        ; cell * 4[R10] (bytes)

        ADRL R0, board
        
        LDR R6, [R0, R8]
        CMP R6, #66
        BGE randu

        STR R7, [R0, R8]     ; puts 66 in board array with offset of R8

        ADD R5, R5, #1        ; count increases by 1

        B neigh

gen1    CMP R5, #8
        BLT randu

        LDMFD R13!, {R0-R10, PC}  
        MOV PC, R14
        
; printBoard -- print the board 
; Input: R0 <-- Address of board
printBoard
        ;STMFD R13!, {R0-R1, R14} 
        ADRL R0, board
        ADRL R6, mine                    ; Copy your implementation of printBoard here 
        ADRL R7, ospace
        ADRL R2, count
        ;ADRL R4, count

        MOV R1, R0                      

        ADRL R3, number
        MOV R0, R3
        SWI 3

        ADRL R0, row
        SWI 3

        MOV R2, #65
        MOV R0, R2
        SWI 0

        ADRL R3, tspace
        MOV R0, R3
        SWI 3

        ADRL R3, tspace
        MOV R0, R3
        SWI 3

        LDR R0, [R1]
        B comp1

next    ADRL R3, tspace
        MOV R0, R3
        SWI 3

        ADD R4, R4, #4
        B check
    
check   CMP R4, #32 
        BEQ newline
        CMP R4, #64
        BEQ newline
        CMP R4, #96
        BEQ newline
        CMP R4, #128
        BEQ newline
        CMP R4, #160
        BEQ newline
        CMP R4, #192
        BEQ newline
        CMP R4, #224
        BEQ newline
        CMP R4, #256
        BEQ ennd

        B secoond

secoond 
        ADRL R3, tspace
        MOV R0, R3
        SWI 3

        LDR R0, [R1, R4]
        B comp1

newline ADRL R0, line
        SWI 3

        ADRL R0, row
        SWI 3

        ADD R2, R2, #1

        MOV R0, R2
        SWI 0

        ADRL R3, ospace
        MOV R0, R3
        SWI 3

        B secoond

comp1   CMP R0, #66
        BGE M

        CMP R0, #0
        BEQ zero

        SWI 4
        B next
        
M       LDR R7, bomb
        STR R7, [R1, R4] 
        MOV R0, R6
        SWI 3
        B next

zero    MOV R0, R7
        SWI 3
        B next

ennd    ;LDMFD R13!, {R0-R1, PC} 
        MOV PC, R14
        

; randu -- Generates a random number
; Input: None
; Ouptut: R0 -> Random number
randu  
        ;STMFD R13!, {R0-R10, R14}                                                 ; Copy your implementation of randu from the previous coursework here
        LDR R0, seed
        LDR R1, magic
        MUL R2, R0, R1  ; R2 = SEED * MAGIC
        LDR R3, mask
        AND R2, R2, R3  ; modulus of / and by 2^31
        MOV R0, R2

        STR R0, seed
       
        MOV R0, R0 ASR #8       ; shift R0 right by 8 bits
        AND R0, R0, #0x3f       ; take the modulo by 64;
        
        MOV R8, R0
                                        
        B generateBoard
        ;LDMFD R13!, {R0-R10, PC}     
        ;MOV PC, R14        ; Your routine to generate the board should be inserted here
                              
neigh   ADRL R0, board
        LDR R1, [R0, R8]
        CMP R1, #66
        BEQ yes

        B gen1

yes     CMP R8, #24
        BLE top
        BGT row1

row1    CMP R8, #32
        BLT te
        BEQ left
        BGT row2

row2    CMP R8, #56
        BLE middle
        BGT row3

row3    CMP R8, #64
        BLT right
        BGT row32
        BEQ left

row32   CMP R8, #88
        BLE middle
        BGT row4

row4    CMP R8, #96
        BGT row42
        BEQ left
        BLT right

row42   CMP R8, #120
        BLE middle
        BGT row5

row5    CMP R8, #128
        BGT row52
        BEQ left
        BLT right

row52   CMP R8, #152
        BLE middle
        BGT row6

row6    CMP R8, #160
        BGT row62
        BEQ left
        BLT right

row62   CMP R8, #184
        BLE middle
        BGT row7

row7    CMP R8, #192
        BGT row72
        BEQ left
        BLT right

row72   CMP R8, #216
        BLE middle
        BGT row8

row8    CMP R8, #224
        BEQ ttf
        BLT right
        BGE bottom

top     CMP R8, #0
        BEQ one

        MOV R2, R8
        SUB R2, R2, #4
        LDR R1, [R0, R2]
        CMP R1, #0
        BLT gen1
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #4
        LDR R1, [R0, R2]
        CMP R1, #0
        BLT gen1
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #28
        LDR R1, [R0, R2]
        CMP R1, #0
        BLT gen1
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #32
        LDR R1, [R0, R2]
        CMP R1, #0
        BLT gen1
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #36
        LDR R1, [R0, R2]
        CMP R1, #0
        BLT gen1
        ADD R1, R1, #1
        STR R1, [R0, R2]

        B gen1

one     MOV R2, R8
        ADD R2, R2, #4
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #32
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #36
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        B gen1

te      MOV R2, R8
        ADD R2, R2, #4
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #32
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #28
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        B gen1

left    MOV R2, R8
        SUB R2, R2, #32
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #32
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #36
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8      
        SUB R2, R2, #28
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #4
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        B gen1

ttf     MOV R2, R8
        SUB R2, R2, #32
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        SUB R2, R2, #28
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #4
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        B gen1

right   MOV R2, R8
        ADD R2, R2, #32
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        SUB R2, R2, #32
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        SUB R2, R2, #4
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        SUB R2, R2, #36
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #28
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2] 

        B gen1  

bottom  CMP R8, #252
        BEQ tft

        MOV R2, R8
        SUB R2, R2, #4
        LDR R1, [R0, R2]
        CMP R1, #252
        BGT gen1
        ADD R1, R1, #1
        STR R1, [R0, R2] 

        MOV R2, R8
        ADD R2, R2, #4
        LDR R1, [R0, R2]
        CMP R1, #252
        BGT gen1
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        SUB R2, R2, #32
        LDR R1, [R0, R2]
        CMP R1, #252
        BGT gen1
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        SUB R2, R2, #36
        LDR R1, [R0, R2]
        CMP R1, #252
        BGT gen1
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        SUB R2, R2, #28
        LDR R1, [R0, R2]
        CMP R1, #252
        BGT gen1
        ADD R1, R1, #1
        STR R1, [R0, R2]

        B gen1

tft     MOV R2, R8
        SUB R2, R2, #32
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]  

        MOV R2, R8
        SUB R2, R2, #4
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]
        
        MOV R2, R8
        SUB R2, R2, #36
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        B gen1


middle  MOV R2, R8
        SUB R2, R2, #4 
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #4
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]
        
        MOV R2, R8
        SUB R2, R2, #28
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        SUB R2, R2, #32
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        SUB R2, R2, #36
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #28
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #32
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        MOV R2, R8
        ADD R2, R2, #36
        LDR R1, [R0, R2]
        ADD R1, R1, #1
        STR R1, [R0, R2]

        B gen1

        
; Insert your subroutine here


