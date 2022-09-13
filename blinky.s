@Hans Tang - ARM Assembly code to run blinking LED game on Raspberry Pi
        .text
        .global _start

        @Base Address 
        .equ BASE_ADDR,     0x3F200000          

        @GPIO Function Selects
        .equ GPFSEL0_MASK,  0x0
        .equ GPFSEL1_MASK,  0x00000004
        .equ GPFSEL2_MASK,  0x00000008
        .equ SELPIN12OUT,   0x40
        .equ SELPIN16OUT,   0x40000
        .equ SELPIN20OUT,   0x1
        .equ SELPIN21OUT,   0x8
        .equ SELPIN26OUT,   0x40000
        .equ SELPIN4IN,     0xFFFF8FFF

        @GPIO Pin Output Set Registers
        .equ GPIOSET0_MASK, 0x0000001C
        .equ SETPIN12,      0x1000
        .equ SETPIN16,      0x10000      
        .equ SETPIN20,      0x100000
        .equ SETPIN21,      0x200000
        .equ SETPIN26,      0x4000000

        @GPIO Pin Output Clear Registers
        .equ GPIOCLR0_MASK, 0x00000028
        .equ CLRPIN12,      0x1000
        .equ CLRPIN16,      0x10000 
        .equ CLRPIN20,      0x100000
        .equ CLRPIN21,      0x200000 
        .equ CLRPIN26,      0x4000000

        @GPIO Pin Level Registers
        .equ GPLEV0_MASK,   0x00000034
        .equ PIN4,          0x10

        @Display Mask
        .equ  DISPLAY_MASK, 0x10


_start:
        @Configuring registers
        mov     r5,  #0                     @Score
        mov     r6,  #3                     @Lives
        mov     r8,  #0                     @Direction, 0 = forward, 1 = backward
        mov     r9,  #0x1e0000              @Speed controller
        mov     r10, #0x1e0000              @Speed controller


        @Configuring Pin output/inputs

        @GPIO 12, output
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPFSEL1_MASK       @GPFSEL1
        ldr     r2,[r1]                     @Load GPFSEL1 into r2
        orr     r2, r2, #SELPIN12OUT        @Turn on pin 12 for output
        str     r2,[r1]                     @Store back into GPFSEL1

        @GPIO 16, output 
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPFSEL1_MASK       @GPFSEL1
        ldr     r2,[r1]                     @Load GPFSEl1 into r2
        orr     r2, r2, #SELPIN16OUT        @Turn on pin 16 for output
        str     r2,[r1]                     @Store back into GPFSEL1
 

        @GPIO 20, output
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPFSEL2_MASK       @GPFSEL2
        ldr     r2,[r1]                     @Load GPFSEL2 into r2
        orr     r2, r2, #SELPIN20OUT        @Turn on pin 20 for output
        str     r2,[r1]                     @Store back into GPFSEL2

        @GPIO 21, output
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPFSEL2_MASK       @GPFSEL2
        ldr     r2,[r1]                     @Load GPFSEL2 into r2
        orr     r2, r2, #SELPIN21OUT        @Turn on pin 21 for output
        str     r2,[r1]                     @Store back into GPFSEL2

        @GPIO 26, output    
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPFSEL2_MASK       @GPFSEL2
        ldr     r2,[r1]                     @Load GPFSEL2 into r2
        orr     r2, r2, #SELPIN26OUT        @Turn on pin 26 for output
        str     r2,[r1]                     @Store back into GPFSEL2

        @GPIO 4, input
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPFSEL0_MASK       @GPFSEL0
        ldr     r2,=SELPIN4IN               @Load mask for selecting pin 4 for input
        ldr     r3,[r1]                     @Load GPFSEL0 into r3
        and     r2, r2, r3                  @Apply mask
        str     r2,[r1]                     @Store back into GPFSEL0


@PROCESSING LED ONE
status_led1:
        mov     r8, #0                      @Direction change

        bl      LED1ON                      @Turn on led 1

        bl      delay1_1                    @branch & link to delay1_1

        cmp     r3, #1                      @Was button pressed?
        bleq    delay3_1                    @Pause led for game playability
        cmp     r3, #1                      @Restore results
        bleq    fail                        @This is a failing led, branch & link to fail

        bl      LED1OFF                     @Turn off led 1


        cmp     r6, #0                      @no mo lives?
        beq     end                         @urrr trashh kidd, game over

        b       status_led2                 @Onto led 2

        
@PROCESSING LED TWO
status_led2:
        bl      LED2ON                      @Turn on led 2

        bl      delay1_1                    @branch & link to delay1_1

        cmp     r3, #1                      @Was button pressed?
        bleq    delay3_1                    @Pause led for game playability
        cmp     r3, #1                      @Restore results
        bleq    fail                        @This is a failing led, branch & link to fail

        bl      LED2OFF                     @Turn off led 2



        cmp     r6, #0                      @no mo lives?
        beq     end                         @urrr trashh kidd, game over

        cmp     r8, #0                      @Direction check
        bne     status_led1                 @Onto led 1 if moving backwards
        beq     status_led3                 @Onto led 3 if moving forwards


@PROCESSING LED THREE
status_led3:
        bl      LED3ON                      @Turn on led 3

        bl      delay2_1                    @Branch & link to delay2_1
    
        cmp     r3, #1                      @Was button pressed?
        bleq    delay3_1                    @Pause led for game playability
        cmp     r3, #1                      @Restore results
        bleq    success                     @This is a winning led, branch & link to success

        bl      LED3OFF                     @Turn off led 3

        cmp     r8, #0                      @Direction check
        bne     status_led2                 @Onto led 2 if moving backwards
        beq     status_led4                 @Onto led 4 if moving forwards


@PROCESSING LED FOUR
status_led4:    
        bl      LED4ON                      @Turn on led 4

        bl      delay1_1                    @Branch & link to delay1_1

        cmp     r3, #1                      @Was button pressed?
        bleq    delay3_1                    @Pause led for game playability
        cmp     r3, #1                      @Resture results
        bleq    fail                        @This is a failing led, branch & link to fail

        bl      LED4OFF                     @Turn off led 4


        cmp     r6, #0                      @no mo lives?
        beq     end                         @urrr trashh kidd, game over

        cmp     r8, #0                      @Direction check
        bne     status_led3                 @Onto led 3 if moving backwards
        beq     status_led5                 @Onto led 5 if moving forwards

        
@PROCESSING LED FIVE
status_led5:
        mov     r8, #1                      @Direction change

        bl      LED5ON                      @Turn on led 5

        bl      delay1_1                    @Branch & link to delay1_1

        cmp     r3, #1                      @Was button pressed?
        bleq    delay3_1                    @Pause led for game playability 
        cmp     r3, #1                      @Restore results
        bleq    fail                        @This is failing led, branch & link to fail

        bl      LED5OFF                     @Turn off led 5

        cmp     r6, #0                      @no mo lives?
        beq     end                         @urrr trashh kidd, game over

        b       status_led4                 @Onto led 4


@delay for led 1, 2, 4, and 5
delay1_1:
        mov     r3, #0                      @Default value
        mov     r9, r10                     @Restore & update counter
delay1_2:
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPLEV0_MASK        @GPLEV0
        ldr     r2,[r1]                     @Load GPLEV0 into r2
        and     r2, r2, #PIN4               @Bit check for pin 4

        cmp     r2, #0                      @Was button pressed?
        moveq   r3, #1                      @Update button status

        sub     r9, r9, #1                  @Decrement counter
        cmp     r9, #0                      @Counter done?
        bne     delay1_2                    @If not, branch to delay1_2
        mov     pc, lr                      @Return from function

@delay for led 3
delay2_1:                   
        mov     r3, #0                      @Default value
        mov     r9, r10                     @Restore & update counter
delay2_2:
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPLEV0_MASK        @GPLEV0
        ldr     r2,[r1]                     @Load GPLEV0 into r2
        and     r2, r2, #PIN4               @Bit check for pin 4

        cmp     r2, #0                      @Was button pressed?
        moveq   r3, #1                      @Update button status

        sub     r9, r9, #1                  @Decrement counter
        cmp     r9, #0                      @Counter done?
        bne     delay2_2                    @If not, branch to delay1_2
        moveq   pc, lr                      @Return from function

delay3_1:
        mov     r2, #0x1E0000               @Restore counter
delay3_2:
        sub     r2, r2, #1                  @Decrement counter
        cmp     r2, #0                      @Counter done?
        bne     delay3_2                    @If not, branch to delay3_2
        mov     pc, lr                      @Return from function



@PROCESSING SUCCESFUL CLICK
success:                            
        add     r5, r5, #1                  @Update score
        sub     r10, r10, #0x40000          @Speed increment (decrement to smaller counter)

        cmp     r10, #0x23C00               @Past too fast?
        movle   r10, #0x23C00               @If so, update speed controller to fastest speed

        mov     pc, lr                      @Return from function

@PROCESSING UNSUCCESSFUL CLICK
fail:  
        sub     r6, r6, #1                  @Decrement lives
        sub     r10, r10, #0x40000          @Speed increment (decrement to smaller counter)

        cmp     r10, #0x23C00               @Past too fast?
        movle   r10, #0x23C00               @If so, update speed controller to fastest speed

        mov     pc, lr                      @Return from function


@END OF GAME
end:

        @Turn on all leds
        bl      LED1ON                                            
        bl      LED2ON                      
        bl      LED3ON                      
        bl      LED4ON                      
        bl      LED5ON                      

        ldr     r0,=DISPLAY_MASK            @Loading display mask into r0
        
        @Bit 5 on?
        and     r1, r5, r0                  
        cmp     r1, #0
        bleq    LED1OFF 

        lsr     r0, #1                      @Update mask to next bit

        @Bit 4 on?
        and     r1, r5, r0 
        cmp     r1, #0
        bleq    LED2OFF 

        lsr     r0, #1                      @Update mask to next bit

        @Bit 3 on?
        and     r1, r5, r0 
        cmp     r1, #0
        bleq    LED3OFF 

        lsr     r0, #1                      @Update mask to next bit
        
        @Bit 2 on?
        and     r1, r5, r0 
        cmp     r1, #0
        bleq    LED4OFF 

        lsr     r0, #1                      @Update mask to next bit

        @Bit 1 on?
        and     r1, r5, r0 
        cmp     r1, #0
        bleq    LED5OFF

end_loop: 
        ldr     r1,=BASE_ADDR               @Loading base address 
        orr     r1, r1, #GPLEV0_MASK        @GPLEV0
        ldr     r2,[r1]                     @Load GPLEV0 into r2
        and     r2, r2, #PIN4               @Bit check for pin 4

        cmp     r2, #0                      @Button pressed?
        bne     end_loop                    @If not, wait for button

        @Reset leds for new game
        bl      LED1OFF
        bl      LED2OFF
        bl      LED3OFF
        bl      LED4OFF       
        bl      LED5OFF    

        bl      delay3_1 
        
        b       _start                      @Start new game

@GPIO 12
LED1ON:                                     @Loading base address
        ldr     r1,=BASE_ADDR
        orr     r1, r1, #GPIOSET0_MASK      @GPIOSET0
        ldr     r2,=SETPIN12                @Load set pin 12 bits
        str     r2,[r1]                     @Store into GPIOSET0
        mov     pc,lr                       @Return from function
LED1OFF:                                    
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPIOCLR0_MASK      @GPIOCLR0
        ldr     r2,=CLRPIN12                @Load clear pin 12 bits
        str     r2,[r1]                     @Store into GPIOSEt0
        mov     pc,lr                       @Return from function

@GPIO16
LED2ON:                                     
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPIOSET0_MASK      @GPIOSET0
        ldr     r2,=SETPIN16                @Load set pin 16 bits
        str     r2,[r1]                     @Store into GPIOSET0    
        mov     pc,lr                       @Return from function
LED2OFF:                                    
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPIOCLR0_MASK      @GPIOCLR0
        ldr     r2,=CLRPIN16                @Load clear pin 16 bits
        str     r2,[r1]                     @Store into GPIOSET0
        mov     pc,lr                       @Return from function

@GPIO 20
LED3ON:                                     
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPIOSET0_MASK      @GPIOSET0
        ldr     r2,=SETPIN20                @Load set pin 20 bits
        str     r2,[r1]                     @Store into GPIOSET0
        mov     pc,lr                       @Return from function
LED3OFF:                                     
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPIOCLR0_MASK      @GPIOCLR0
        ldr     r2,=CLRPIN20                @Load clear pin 20 bits
        str     r2,[r1]                     @Store into GPIOCLR0
        mov     pc,lr                       @Return from function

@GPIO 21
LED4ON:                                     
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPIOSET0_MASK      @GPIOSET0
        ldr     r2,=SETPIN21                @Load set pin 21 bits
        str     r2,[r1]                     @Store into GPIOSET0
        mov     pc,lr                       @Return from function
LED4OFF:                                    
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPIOCLR0_MASK      @GPIOCLR0
        ldr     r2,=CLRPIN21                @Load clear pin 21 bits
        str     r2,[r1]                     @Store into GPIOCLR0
        mov     pc,lr                       @Return from function

@GPIO 26
LED5ON:                                     
        ldr     r1,=BASE_ADDR               @Loading base address
        orr     r1, r1, #GPIOSET0_MASK      @GPIOSET0
        ldr     r2,=SETPIN26                @Load set pin 26 bits   
        str     r2,[r1]                     @Store into GPIOSET0
        mov     pc,lr                       @Return from function
LED5OFF:                                    
        ldr     r1,=BASE_ADDR               @loading base addres
        orr     r1, r1, #GPIOCLR0_MASK      @GPIOCLR0
        ldr     r2,=CLRPIN26                @Load clear pin 26 bits
        str     r2,[r1]                     @Store into GPIOCLR0
        mov     pc,lr                       @Return from
