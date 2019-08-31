; 6510 asm code fills the entire screen with first A then B... to Z then reset back to a and loop forever

; 10 SYS (2064)

*=$0801

        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $32, $30, $36, $34, $29, $00, $00, $00

*=$0810

loc_CharToPutOnScreen = $0f00
charToStart = #01
SCREENRAM       = $0400
          
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
          
          

          lda            charToStart  
          sta            loc_CharToPutOnScreen     
start
          WAIT_FOR_RASTER          ; wait for the crt scan to go off visible part of screen
                                   ; this stop partial update to screen an avoids flicker
          LIBSCREEN_SET1000 SCREENRAM, loc_CharToPutOnScreen
          ldx            loc_CharToPutOnScreen    ; increment the character to add to screen
          inx
          cpx            #26     
          beq            resetChar
continueAfterReset  
          stx            loc_CharToPutOnScreen    
          jmp            start     
          
         
resetChar    ; load register with starting character to reset it 
          ldx            charToStart  
          jmp            continueAfterReset
          
          
