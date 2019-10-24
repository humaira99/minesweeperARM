    B main
        ALIGN 
prompt  DEFB "Enter square to reveal: ",0
mesg    DEFB "\n You entered the index ",0
error   DEFB "Error: invalid input. Restart\n",0
        ALIGN
four    DEFW    4
row     DEFW    0
column  DEFW    0
eight   DEFW    8

        ALIGN
main    ADRL R0, prompt
        BL boardSquareInput

        MOV R1, R0
        ADR R0, mesg
        SWI 3
        MOV R0, R1
        SWI 4
        MOV R0,#10
        SWI 0
        SWI 2


; boardSquareInput -- read board position from keyboard
; Input:  R0 ---> prompt string address
; Ouptut: R0 <--- index

boardSquareInput
        STMFD R13!, {R1-R4}   
repeat  
        ADR r0, prompt
        SWI 3

        SWI 1
        SWI 0

        CMP R0, #64
        BLE wrong
        CMP R0, #73
        BGE check

        CMP R0, #64
        BGT caps

check   CMP R0, #105
        BGE wrong
        CMP R0, #96
        BLE wrong  
        CMP R0, #97
        BGE lower 

wrong   ADRL R0, error
        SWI 3
        B repeat
        
caps    SUB R0, R0, #65
        STR R0, row
        B number

lower   SUB R0, R0, #97
        STR R0, row
        B number

number  SWI 1
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
        BEQ index

index   LDR R1, row
        LDR R2, column  
        ;LDR R3, four
        LDR R4, eight

        MLA R0, R4, R1, R2          ; 8c+r        
        ;MUL R0, R0, R3
        LDMFD R13!, {R1-R4}
        MOV PC, R14