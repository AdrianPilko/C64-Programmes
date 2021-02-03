; 10 SYS (2304)

*=$0801

        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $32, $33, $30, $34, $29, $00, $00, $00

incloopcnt = $0e0f
previousShotPlayerPos = $0E0c
previousShotAddr = $0E0b
shootFlagAddr = $0E0a
shotStartPosAddr =$0E09
shotChar = 3
shotaddr=$0e0d
temp = $0E08
shootPlayerAddr = $0E07
playerChar = 68
playerCharAddr =$0E06
playerMvFlagL = $0E03
playerMvFlagR = $0E04
playerStopFlag = $0E05          
playerAddr = $0E00
alienStaAddr = $0E01         
myStack = $0E02
keyRowAddr = $dc00          
keyColAddr = $dc01
dispBColour = $d020
blackColour = 0
whiteColour = 1
tb1Colour = 2
tb2Colour = 3

*=$0900

Main
        ; border color initialization
        lda #$00        ; set startup border color to black
        sta $d020       ; which means "no match"
        
        ; next 4 lines are for the delay loop
counter = $fa ; a zeropage address to be used as a counter
        lda #$00    ; reset
        sta counter ; counter
;;;;; NO!!        sei       ; enable interrupts
          jsr            initSCR     ; subroutine to initialise screen
          jsr            initPlayer  ; subroutine to initialise player position
          jsr            initAliens; subroutine to initialise aliens positions
          ldx #00
gameLoop
          lda #01
          sta incloopcnt
incloop
          jsr incAlienPos
          jsr update
          clc
          inc incloopcnt
          lda incloopcnt
          cmp #10
          bne incloop
decloop
          jsr decAlienPos 
          jsr update
          clc
          dec incloopcnt
          lda incloopcnt
          cmp #01
          bne decloop
          clc
          lda alienStaAddr
         adc #40
         cmp #240
         bmi resetali
         sta alienStaAddr                
          jmp            gameLoop
resetali
          jsr initAliens
          jmp gameLoop
          rts
          

incAlienPos      
          stx myStack
          ldx alienStaAddr   
          inx
          stx alienStaAddr
          ldx myStack
          rts
decAlienPos
          stx myStack
           ldx alienStaAddr   
          dex
          stx            alienStaAddr
          ldx myStack
          rts         
delayCode
          sta myStack
          lda            #$fb      ; wait for vertical retrace
loop2     cmp            $d012     ; until it reaches 251th raster line ($fb)
          bne            loop2     ; which is out of the inner screen area
          inc            counter   ; increase frame counter         
          lda            counter   ; check if counter         
          cmp            #$32      ; reached 50         
          bne            out       ; if not, pass the color changing routine
          lda            #$00      ; reset     
          sta            counter   ; counter      
out
          lda            $d012     ; make sure we reached       
loop3     cmp            $d012     ; the next raster line so next time we          
          beq            loop3     ; should catch the same line next frame        
          lda myStack
          rts

          

update
          ldx            alienStaAddr   
          jsr            drawAliens
          jsr            drawPlayer
          jsr            delayPt2Sec 
          jsr            clearPlayer 
          jsr            readKey
          jsr            clearAliens
          jsr            movePlayer
          jsr            shootPlayer
          rts


delayPt2Sec
          jsr            delayCode 
          jsr            delayCode 
          jsr            delayCode 
          jsr            delayCode 
          jsr            delayCode 
          jsr            delayCode 
          jsr            delayCode 
          jsr            delayCode 
          jsr            delayCode 
          jsr            delayCode 
          jsr            delayCode
          rts
          
drawAliens    ; use character c1 for aliens
   
          ldx            alienStaAddr ;#214 
          lda            #65    ; alien character (should use udg)
          jsr drawal
          rts
drawal
;row one       
         sta             $4d0,x    
          sta            $4d2,x    
          sta            $4d4,x 
          sta            $4d6,x    
          sta            $4d8,x    
          sta            $4da,x  
          sta            $4dc,x   
          sta            $4de,x
; row two    
         sta            $520,x    
          sta            $522,x 
         sta            $524,x    
          sta            $526,x   
         sta            $528,x
          sta            $52a,x
         sta            $52c,x
          sta            $52e,x
; row three
          sta            $570,x    
         sta            $572,x 
          sta            $574,x    
          sta            $576,x    
         sta            $578,x
        sta            $57a,x
         sta            $57c,x
          sta            $57e,x    
; row four
         sta            $5c0,x    
         sta            $5c2,x 
        sta            $5c4,x    
         sta            $5c6,x    
         sta            $5c8,x
         sta            $5ca,x
        sta            $5cc,x
         sta            $5ce,x    
          rts
          

clearAliens    ; use blank space character to clear aliens
          ldx             alienStaAddr ;#214 
          lda            #32    ; alien character (should use udg)
          jsr drawal
          rts  
  

          
initPlayer                         ; store the player position at $0E00
          lda            #20    ; start of in middle of screen
          sta            playerAddr
          lda            #0
          sta            playerMvFlagL
          lda            #0        
          sta            playerMvFlagR
          lda            #0
          sta            playerStopFlag
          
          lda            playerChar
          sta            playerCharAddr
          lda #00 
          sta previousShotPlayerPos
          rts
clearPlayer
          sta            myStack
          ldx            playerAddr
          lda            #32    
          sta            $797,x         
          sta            $798,x    
          lda myStack  ; put A back
          rts
          
drawPlayer
          sta            myStack
          ldx            playerAddr
          lda            playerCharAddr
          sta            $797,x
          sta            $798,x  
          lda myStack     
          rts
          
          
initAliens                      
          lda            #00   ; this is just the offset from to left   
          sta alienStaAddr   
          rts

initSCR
          lda            #$16       ; load $17, decimal 23 the code for character set 2   
          sta            $d018      ; store in the screen char set control byte
          lda            #$00      
          sta            $d020      ; clear the screen
          sta            $d021     
          tax
          lda            #$20       
loop      sta            $0400,x          
          sta            $0500,x             
          sta            $0600,x             
          sta            $0700,x   
          dex
          bne            loop      
          
          ldx            #0         ; init X register with $00
loopSCR_I lda            TitleLine,x    ; read characters from lineA table of text...
          sta            $400,x    ; ...and store in screen ram at top line
          lda            UTitle,x  ; load and store spacer line
          sta            $428,x    
          lda            scoreLine,x  ; load and store score line (this has dummy values in)
          sta            $450,x   
          lda            protectorA,x  ; load and store defences first line 
          sta            $6f8,x    
          sta            $720,x  
          inx 
          cpx            #$28       ; finished when all 40 cols of a line are processed
          bne            loopSCR_I  ; loop if we are not done yet
          rts
          
TitleLine 
        text       "     ADE'S EXCELLENT SPACE INVADERS     "
UTitle   
        text          "========================================"
scoreLine 
        text          "1UP SCORE 0000000      2UP SCORE 0000000"
protectorA
        text          "          ###   ###  ###   ###          "
         

;;; key press sub
readKey
          jsr            $ffe4     ; read key
          cmp #0
        beq returnFromReadKey     ; if no key pressed loop forever
       ; jsr $ffd2       ; show key on the screen
        
        cmp #65      ; left "A" key pressed
        beq cmpMatchL    ; if there is a match jmp to cmpMatch           
        cmp #76   ; right "L key pressed
          beq            cmpMatchR ; if there is a match jmp to cmpMatch
          cmp            #32       
          beq  space_pressed
        lda #$04        
        sta            $d020     ; change border color to show no key  
        rts
returnFromReadKey
          rts
cmpMatchL
        lda #$02        
        sta            $d020     ; change border color to red
        jsr            left_move 
        rts
cmpMatchR
        lda #$01        
        sta            $d020     ; change border color to white
          jsr            right_move
          rts
space_pressed    ; stop the player and shoot
          lda            #0
          sta            playerMvFlagL
          lda            #0        
          sta            playerMvFlagR
          lda            #1
          sta            shootFlagAddr 
          rts
          
left_move
          ldx            playerAddr  ; location of offset to player on the screen row     
          dex
          cpx            #0        
          beq            gorts_lm  
          jsr            incBoarder
          stx            playerAddr
          lda            #1
          sta            playerMvFlagL
          lda            #0        
          sta            playerMvFlagR
          lda            #0
          sta            playerStopFlag
          rts
gorts_lm
          rts
right_move
          ldx            playerAddr    
          inx
          cpx            #40        
          beq            gorts_rm  
          jsr            decBoarder
          stx            playerAddr    
          lda            #0
          sta            playerMvFlagL
          lda            #1        
          sta            playerMvFlagR
          lda            #0
          sta            playerStopFlag 
          rts
gorts_rm
          rts

shootPlayer
          inc shootFlagAddr
          lda            shootFlagAddr
          
         cmp            #1        
         beq            fireShot
          lda            shootFlagAddr
          cmp            #2        
          beq            fireShot
          lda            shootFlagAddr
          cmp            #3        
          beq            fireShot
          lda            #00 
         sta            shootFlagAddr
         rts
          
movePlayer
          lda            playerMvFlagL
          cmp            #1        
          beq            left_move
          lda            playerMvFlagR
          cmp            #1        
          beq            right_move
          rts


                
fireShot
          
          ldx            playerAddr
          lda            shotChar  
          sta            shotaddr,x      
          lda            #32       
          ldx            previousShotPlayerPos
          sta            previousShotAddr,x
          lda shotaddr
          sta            previousShotAddr
          ldx playerAddr
          stx previousShotPlayerPos
          inc            shootFlagAddr  
          jsr incBoarder        
          rts
          
incBoarder
          inc            dispBColour
          rts
decBoarder
          dec            dispBColour
          rts

