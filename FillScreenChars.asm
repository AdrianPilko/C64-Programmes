; 10 SYS (2064)

*=$0801

        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $32, $30, $36, $34, $29, $00, $00, $00

*=$0810

charToStart = #01
SCREENRAM = $0400

          jmp            initCode  
          

loc_CharToPutOnScreen
          brk
loc_backgroundColour
          brk
          
libDelay_one
          brk
          brk
loc_delayVal
          brk ; 16bit first bytes
          brk ; 16bit second byte
          
defm    LIBMATH_SUB16BIT_AAA
                ; /1 = 1st Number word (Address)
                ; /2 = 2nd Number word (Address)
                ; /3 = 3rd Number word (Address)
                
        sec     ; sec is the same as clear borrow
        lda /1  ; Get LSB of first number
        sbc /2 ; Subtract LSB of second number
        sta /3  ; Store in LSB of sum
        lda /1+1  ; Get MSB of first number
        sbc /2+1 ; Subtract borrow and MSB of NUM2
        sta /3+1  ; Store sum in MSB of sum
endm

          
; Sets 1000 bytes of memory from start address with a value
defm    LIBSCREEN_SET1000       ; /1 = Start  (Address)
                                ; /2 = Number (Adress)

        lda /2                 ; Get number to set
        ldx #250                ; Set loop value
@loop   dex                     ; Step -1
        sta /1,x                ; Set start + x
        sta /1+250,x            ; Set start + 250 + x
        sta /1+500,x            ; Set start + 500 + x
        sta /1+750,x            ; Set start + 750 + x
        bne @loop               ; If x<>0 loop

        endm

defm      WAIT_FOR_RASTER

raster_check     
          lda            $d012     ; check the raster off visible screen
          cmp            #01        
          bne            raster_check
endm


initCode          
         
          lda            charToStart  
          sta            loc_CharToPutOnScreen     
start
          WAIT_FOR_RASTER          ; wait for the crt scan to go off visible part of screen
                                   ; this stop partial update to screen an avoids flicker
          LIBSCREEN_SET1000 SCREENRAM,loc_CharToPutOnScreen

          ldx            loc_backgroundColour
          stx            $d021
          inx
          cpx            #16       
          bne            skipresetBackgroundColour
          jsr resetBackgroundColour
skipresetBackgroundColour
          stx            loc_backgroundColour          
          jsr            LIBDELAY  
          ldx            loc_CharToPutOnScreen    ; increment the character to add to screen
          inx
          cpx            #27   
          bne skipResetChar           
          jsr resetChar 
skipResetChar 
          stx            loc_CharToPutOnScreen    
          jmp            start     
          
         
resetChar    ; load register with starting character to reset it 
          ldx            charToStart  
          rts
resetBackgroundColour ; reset the colour value for the background colour          
          ldx            #00       
          rts     
          

LIBDELAY
          lda            #01        
          sta            libDelay_one
          lda            #00       
          sta            libDelay_one+1          
          lda            #$00
          sta            loc_delayVal
          lda            #$30      
          sta            loc_delayVal+1
libDelay_loop
          LIBMATH_SUB16BIT_AAA loc_delayVal, libDelay_one, loc_delayVal
         
          ldx            loc_delayVal
          cpx            #0        
          bne libDelay_loop
          ldx            loc_delayVal+1                
          cpx            #0        
          bne libDelay_loop          
          rts
