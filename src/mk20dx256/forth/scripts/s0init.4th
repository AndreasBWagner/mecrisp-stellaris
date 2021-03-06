compiletoflash
$40064000 constant MCG_C1
$40064001 constant MCG_C2
$40064002 constant MCG_C3
$40064003 constant MCG_C4
$40064004 constant MCG_C5
$40064005 constant MCG_C6
$40064006 constant MCG_S
$40064008 constant MCG_SC
$40065000 constant OSC_CR
$40048044 constant SIM_CLKDIV1
$40048048 constant SIM_CLKDIV2
$40048034 constant SIM_SCGC4
$40048004 constant SIM_SOPT2
: mcg-osc-ready? 2 MCG_S cbit@ ; 
: mcg-extref-refclock? $10 MCG_S cbit@ not ;
: mcg-extref-outclk? MCG_S c@ $0C and $8 = ;
: mcg-pll-lock? 64 MCG_S cbit@ ;
: mcg-pll-use-crystal? 32 MCG_S cbit@ ;
: MCG_96MHz ( -- ) 
10 OSC_CR c! 
$24 MCG_C2 c!
2 6 lshift 4 3 lshift + MCG_C1 C!
begin mcg-osc-ready? until 
begin mcg-extref-refclock? until
begin mcg-extref-outclk? until 
3 MCG_C5 c! 
1 6 lshift MCG_C6 c! 
begin mcg-pll-use-crystal? until
begin mcg-pll-lock? until 
$01030000 SIM_CLKDIV1 !
4 3 lshift MCG_C1 C! 
begin MCG_S c@ $0C and $0C = until 
;
$4006A000 constant UART0_BASE
$4006A015 constant UART0_RWFIFO
: UART_96MHz_115200 ( -- )
 0 UART0_BASE c!
 52 [ UART0_BASE 1 + literal, ] c!
 3 [ UART0_BASE $A + literal, ] c!
;
: USB_96MHz_48MHZ ( -- )
 2 SIM_CLKDIV2 !
 $510C0 SIM_SOPT2 !
;
: fullspeed 0 uart0_rwfifo c! MCG_96MHz UART_96MHz_115200 6 uart0_rwfifo c! ;
fullspeed
\ Add a comment line ... it often gets garbled when the uart clock changes
: init fullspeed CR ." Running at 96MHz" CR ;
init
: .fault ipsr ." Unhandled fault #" . CR ;
' .fault irq-fault !
: irq-enable-mask-offset ( IRQ -- mask offset)
 dup $1F and 1 swap lshift 
 swap $E0 and 3 rshift 
;
: irq-enable ( IRQ -- )
 irq-enable-mask-offset
 $E000E100 + !
;
: irq-disable ( IRQ -- ) 
 irq-enable-mask-offset
 $E000E180 + !
;
: irq-trigger ( IRQ -- )
 $E000EF00 !
;
$4006A000 constant UART0_BDH
$4006A001 constant UART0_BDL
$4006A002 constant UART0_C1
$4006A003 constant UART0_C2
$4006A004 constant UART0_S1
$4006A005 constant UART0_S2
$4006A006 constant UART0_C3
$4006A007 constant UART0_D
$4006A008 constant UART0_MA1
$4006A009 constant UART0_MA2
$4006A00A constant UART0_C4
$4006A00B constant UART0_C5
$4006A00C constant UART0_ED
$4006A00D constant UART0_MODEM
$4006A00E constant UART0_IR
$4006A010 constant UART0_PFIFO
$4006A011 constant UART0_CFIFO
$4006A012 constant UART0_SFIFO
$4006A013 constant UART0_TWFIFO
$4006A014 constant UART0_TCFIFO
$4006A015 constant UART0_RWFIFO
$4006A016 constant UART0_RCFIFO
%00001100 constant UART0_RETE
%00000100 constant UART0_RE
: uart0e-status ( -- )
 UART0_S1 c@
 dup $08 and 0<> if ." Receiver overrun error" CR then
 dup $04 and 0<> if ." Noise error" CR then
 dup $02 and 0<> if ." Framing error" CR then
 $01 and 0<> if ." Parity error" CR then
 UART0_SFIFO c@
 dup $04 and 0<> if ." Receiver buffer overflow error" CR then
 dup $02 and 0<> if ." Transmitter buffer overflow error" CR then
 $01 and 0<> if ." Receiver buffer underflow error" CR then
;
: uart0e-clear ( -- )
 uart0_s1 c@ uart0_d c@
 %11000111 uart0_cfifo c!
 %00000111 uart0_sfifo c!
 46 irq-enable-mask-offset $E000E280 + !
;
: uart0e-eint 
 %00101100 uart0_c2 c!
 %00001111 uart0_c3 c!
 %00000111 uart0_cfifo c!
 46 irq-enable
;
: Uart0e-isr
 CR ." Recieved UART0 Error interupt:" CR
 uart0e-status
 uart0e-clear
;
: uart0-disable ( -- ) UART0_RETE UART0_C2 cbic! ;
: uart0-enable ( -- ) UART0_RETE UART0_C2 cbis! ;
: uart0-re-disable ( -- ) UART0_RE UART0_C2 cbic! ;
: uart0-re-enable ( -- ) UART0_RE UART0_C2 cbis! ;
: uart0-fifo-size-set ( n -- ) uart0-re-disable uart0_rwfifo c! uart0-re-enable ;
' uart0e-isr irq-uart0e !
uart0e-eint
$400FF000 constant GPIOA_PDOR 
$400FF004 constant GPIOA_PSOR 
$400FF008 constant GPIOA_PCOR 
$400FF00C constant GPIOA_PTOR 
$400FF010 constant GPIOA_PDIR 
$400FF014 constant GPIOA_PDDR 
$400FF040 constant GPIOB_PDOR 
$400FF044 constant GPIOB_PSOR 
$400FF048 constant GPIOB_PCOR 
$400FF04C constant GPIOB_PTOR 
$400FF050 constant GPIOB_PDIR 
$400FF054 constant GPIOB_PDDR 
$400FF080 constant GPIOC_PDOR 
$400FF084 constant GPIOC_PSOR 
$400FF088 constant GPIOC_PCOR 
$400FF08C constant GPIOC_PTOR 
$400FF090 constant GPIOC_PDIR 
$400FF094 constant GPIOC_PDDR 
$400FF0C0 constant GPIOD_PDOR 
$400FF0C4 constant GPIOD_PSOR 
$400FF0C8 constant GPIOD_PCOR 
$400FF0CC constant GPIOD_PTOR 
$400FF0D0 constant GPIOD_PDIR 
$400FF0D4 constant GPIOD_PDDR 
$400FF100 constant GPIOE_PDOR 
$400FF104 constant GPIOE_PSOR 
$400FF108 constant GPIOE_PCOR 
$400FF10C constant GPIOE_PTOR 
$400FF110 constant GPIOE_PDIR 
$400FF114 constant GPIOE_PDDR 
$40049000 constant PORTA_PCR
$40049080 constant PORTA_GPCLR
$40049084 constant PORTA_GPCHR
$4004A000 constant PORTB_PCR
$4004A080 constant PORTB_GPCLR
$4004A084 constant PORTB_GPCHR
$4004B000 constant PORTC_PCR
$4004B080 constant PORTC_GPCLR
$4004B084 constant PORTC_GPCHR
$4004C000 constant PORTD_PCR
$4004C080 constant PORTD_GPCLR
$4004C084 constant PORTD_GPCHR
$4004D000 constant PORTE_PCR
$4004D080 constant PORTE_GPCLR
$4004D084 constant PORTE_GPCHR
$E000E010 constant NVIC_ST_CTRL_R
$E000E014 constant NVIC_ST_RELOAD_R 
$E000E018 constant NVIC_ST_CURRENT_R
: delay-init ( -- )
 0 NVIC_ST_CTRL_R !
 $00FFFFFF NVIC_ST_RELOAD_R !
 0 NVIC_ST_CURRENT_R !
 %101 NVIC_ST_CTRL_R !
;
: delay-ticks ( ticks -- )
 NVIC_ST_RELOAD_R ! 
 0 NVIC_ST_CURRENT_R ! 
 begin
 $10000 NVIC_ST_CTRL_R bit@ 
 until
;
: us ( us -- ) 96 * delay-ticks ;
: ms ( ms -- ) 0 ?do 96000 delay-ticks loop ;
: hundredms ( hundredms -- ) 0 ?do 9600000 delay-ticks loop ;
: sec ( secs -- ) 10 * 1 do 1 hundredms loop ;
: 10s-Pulse ( -- )
 delay-init
 10 sec
;
$E000E010 constant NVIC_ST_CTRL_R
$E000E014 constant NVIC_ST_RELOAD_R
$E000E018 constant NVIC_ST_CURRENT_R
: systick-eint %111 NVIC_ST_CTRL_R ! ;
: systick-dint 0 NVIC_ST_CTRL_R ! ;
: systick-reset 0 NVIC_ST_CURRENT_R ! ;
: systick-reload-set ( ticks -- ) NVIC_ST_RELOAD_R ! ;
: systick-init ( ticks -- )
 systick-dint
 systick-reload-set
 systick-reset
 systick-eint eint
;
: led-init
 $0100 5 4 * PORTC_PCR + !
 $20 GPIOC_PDDR !
;
: led-on $20 GPIOC_PSOR bis! ;
: led-off $20 GPIOC_PCOR bis! ;
: blink ( n -- )
 led-init
 delay-init
 0 do led-on 3 hundredms led-off 3 hundredms loop
;
: led-toggle ( -- )
 $20 GPIOC_PTOR bis!
;
: led-pulse ( -- ) 
 led-init
 ['] led-toggle irq-systick ! 
 $FFFFFF systick-init 
;
: spaces 0 ?do space loop ;
: star 42 emit ;
: Flamingo cr
."      _" cr
."     ^-)" cr
."      (.._          .._" cr
."       \`\\        (\`\\        (" cr
."        |>         ) |>        |)" cr
." ______/|________ (7 |` ______\|/_______a:f" cr
;
: Buddha cr
."                              _" cr
."                           _ooOoo_" cr
."                          o8888888o" cr
."                          88~ . ~88" cr
."                          (| -_- |)" cr
."                          O\  =  /O" cr
."                       ____/`---'\____" cr
."                     .'  \\|     |//  `." cr
."                    /  \\|||  :  |||//  \" cr
."                   /  _||||| -:- |||||_  \" cr
."                   |   | \\\  -  /'| |   |" cr
."                   | \_|  `\`---'//  |_/ |" cr
."                   \  .-\__ `-. -'__/-.  /" cr
."                 ___`. .'  /--.--\  `. .'___" cr
."              .// '<  `.___\_<|>_/___.' _> \''." cr
."             | | :  `- \`. ;`. _/; .'/ /  .' ; |" cr
."             \  \ `-.   \_\_`. _.'_/_/  -' _.' /" cr
."   ===========`-.`___`-.__\ \___  /__.-'_.'_.-'================" cr
."                           `=--=-'                    hjw" cr
;
: init
 fullspeed
 delay-init
 led-init
 ['] .fault irq-fault !
 ['] uart0e-isr irq-uart0e !
 uart0e-eint
 ." Running at 96MHz" CR 
 cr
 Buddha
 cr
 ." An idea that is developed and put into action is more important"
 CR ." than an idea that exists only as an idea. " CR
;
: list ( -- )
 cr
 dictionarystart 
 begin
 dup 6 + ctype space
 dictionarynext
 until
 drop
;
0 variable disasm-$ 
: disasm-fetch 
 disasm-$ @ h@ 
 2 disasm-$ +! ;
: disasm-string ( -- )
 disasm-$ @ dup ctype skipstring disasm-$ !
;
: name. ( Address -- )
 1 bic
 >r
 dictionarystart
 begin
 dup 6 + dup skipstring r@ = if ."   --> " ctype else drop then
 dictionarynext
 until
 drop
 r> 
 case \ Check for inline strings ! They are introduced by calls to ." or s" internals.
 ['] ." $1E + of ." --> .' " disasm-string ." '" endof \ It is ." runtime ?
    ['] s" $4 + of ."   -->  s' " disasm-string ." '" endof
    ['] c" $4 + of ."   -->  c' " disasm-string ." '" endof
 endcase
;
: u.4 0 <# # # # # #> type ;
: u.8 0 <# # # # # # # # # #> type ;
: u.ns 0 <# #s #> type ;
: const. ."  #" u.ns ;
: addr. u.8 ;
: register. ( u -- )
 case 
 13 of ."  sp" endof
 14 of ."  lr" endof
 15 of ."  pc" endof
 dup ."  r" decimal u.ns hex 
 endcase ;
: opcode? ( Opcode Bits Mask -- Opcode ? )
 swap >r ( Opcode Mask )
 over and ( Opcode Opcode* )
 r> ( Opcode Opcode* Bits )
 = ( Opcode Flag )
;
: reg. ( Opcode Position -- Opcode ) over swap rshift $7 and register. ;
: reg16. ( Opcode Position -- Opcode ) over swap rshift $F and register. ;
: reg16split. ( Opcode -- Opcode ) dup $0007 and over 4 rshift $0008 and or register. ;
: registerlist. ( Opcode -- Opcode ) 8 0 do dup 1 i lshift and if i register. space then loop ;
: imm3. ( Opcode Position -- Opcode ) over swap rshift $7 and const. ;
: imm5. ( Opcode Position -- Opcode ) over swap rshift $1F and const. ;
: imm8. ( Opcode Position -- Opcode ) over swap rshift $FF and const. ;
: imm3<<1. ( Opcode Position -- Opcode ) over swap rshift $7 and shl const. ;
: imm5<<1. ( Opcode Position -- Opcode ) over swap rshift $1F and shl const. ;
: imm8<<1. ( Opcode Position -- Opcode ) over swap rshift $FF and shl const. ;
: imm3<<2. ( Opcode Position -- Opcode ) over swap rshift $7 and shl shl const. ;
: imm5<<2. ( Opcode Position -- Opcode ) over swap rshift $1F and shl shl const. ;
: imm7<<2. ( Opcode Position -- Opcode ) over swap rshift $7F and shl shl const. ;
: imm8<<2. ( Opcode Position -- Opcode ) over swap rshift $FF and shl shl const. ;
: condition. ( Condition -- )
 case
 $0 of ." eq" endof 
 $1 of ." ne" endof 
 $2 of ." cs" endof 
 $3 of ." cc" endof 
 $4 of ." mi" endof 
 $5 of ." pl" endof 
 $6 of ." vs" endof 
 $7 of ." vc" endof 
 $8 of ." hi" endof 
 $9 of ." ls" endof 
 $A of ." ge" endof 
 $B of ." lt" endof 
 $C of ." gt" endof 
 $D of ." le" endof 
 endcase
;
: rotateleft ( x u -- x ) 0 ?do rol loop ;
: rotateright ( x u -- x ) 0 ?do ror loop ;
: imm12. ( Opcode -- Opcode )
 dup $FF and 
 over 4 rshift $700 and or 
 over 15 rshift $800 and or 
 ( Opcode imm12 )
 dup 8 rshift
 case
 0 of $FF and const. endof
 1 of $FF and dup 16 lshift or const. endof
 2 of $FF and 8 lshift dup 16 lshift or const. endof
 3 of $FF and dup 8 lshift or dup 16 lshift or const. endof
 swap
 dup 7 rshift swap $7F and $80 or swap rotateright const.
 endcase
;
0 variable destination-r0
: disasm-thumb-2 ( Opcode16 -- Opcode16 )
 dup 16 lshift disasm-fetch or ( Opcode16 Opcode32 )
 $F000D000 $F800D000 opcode? if 
 ( Opcode )
 ." bl  "
 dup $7FF and ( Opcode DestinationL )
 over ( Opcode DestinationL Opcode )
 16 rshift $7FF and ( Opcode DestinationL DestinationH )
 dup $400 and if $FFFFF800 or then ( Opcode DestinationL DestinationHsigned )
 11 lshift or ( Opcode Destination )
 shl 
 disasm-$ @ +
 dup addr. name.
 then
 $F2400000 $FB708000 opcode? if
 ( Opcode )
 dup $00800000 and if ." movt"
 else ." movw"
 then
 8 reg16.
 dup $FF and ( Opcode Constant* )
 over $7000 and 4 rshift or ( Opcode Constant** )
 over $04000000 and 15 rshift or ( Opcode Constant*** )
 over $000F0000 and 4 rshift or ( Opcode Constant )
 dup ."  #" u.4
 ( Opcode Constant )
 over $00800000 and if 16 lshift destination-r0 @ or destination-r0 !
 else destination-r0 !
 then
 then
 $F0000000 $FA008000 opcode? not if else
 dup 21 rshift $F and
 case
 %0000 of ." and" endof
 %0001 of ." bic" endof
 %0010 of ." orr" endof
 %0011 of ." orn" endof
 %0100 of ." eor" endof
 %1000 of ." add" endof
 %1010 of ." adc" endof
 %1011 of ." sbc" endof
 %1101 of ." sub" endof
 %1110 of ." rsb" endof
 ." ?"
 endcase
 dup 1 20 lshift and if ." s" then
 8 reg16. 16 reg16.
 imm12.
 then
 case \ Decode remaining "singular" opcodes used in Mecrisp-Stellaris:
 $EA5F0676 of ." rors r6 r6 #1" endof
 $F8476D04 of ." str r6 [ r7 #-4 ]!" endof
 $F8576026 of ." ldr r6 [ r7 r6 lsl #2 ]" endof
 $F85D6C08 of ." ldr r6 [ sp #-8 ]" endof
 $FAB6F686 of ." clz r6 r6" endof
 $FB90F6F6 of ." sdiv r6 r0 r6" endof
 $FBB0F6F6 of ." udiv r6 r0 r6" endof
 $FBA00606 of ." umull r0 r6 r0 r6" endof
 $FBA00806 of ." smull r0 r6 r0 r6" endof
 endcase
 ( Opcode16 )
;
: disasm ( -- )
disasm-fetch
$4140 $FFC0 opcode? if ." adc" 0 reg. 3 reg. then 
$1C00 $FE00 opcode? if ." adds" 0 reg. 3 reg. 6 imm3. then 
$3000 $F800 opcode? if ." adds" 8 reg. 0 imm8. then 
$1800 $FE00 opcode? if ." adds" 0 reg. 3 reg. 6 reg. then 
$4400 $FF00 opcode? if ." add" reg16split. 3 reg16. then 
$A000 $F800 opcode? if ." add" 8 reg. ." pc " 0 imm8. then 
$A800 $F800 opcode? if ." add" 8 reg. ." sp " 0 imm8. then 
$B000 $FF80 opcode? if ." add sp" 0 imm7<<2. then 
$4000 $FFC0 opcode? if ." ands" 0 reg. 3 reg. then 
$1000 $F800 opcode? if ." asrs" 0 reg. 3 reg. 6 imm5. then 
$4100 $FFC0 opcode? if ." asrs" 0 reg. 3 reg. then 
$D000 $F000 opcode? not if else dup $0F00 and 
 case
 $0000 of ." beq" endof 
 $0100 of ." bne" endof 
 $0200 of ." bcs" endof 
 $0300 of ." bcc" endof 
 $0400 of ." bmi" endof 
 $0500 of ." bpl" endof 
 $0600 of ." bvs" endof 
 $0700 of ." bvc" endof 
 $0800 of ." bhi" endof 
 $0900 of ." bls" endof 
 $0A00 of ." bge" endof 
 $0B00 of ." blt" endof 
 $0C00 of ." bgt" endof 
 $0D00 of ." ble" endof 
 endcase
 space
 dup $FF and dup $80 and if $FFFFFF00 or then
 shl disasm-$ @ 1 bic + 2 + addr. 
 then
$E000 $F800 opcode? if ." b" 
 dup $7FF and shl
 dup $800 and if $FFFFF000 or then
 disasm-$ @ + 2+ 
 space addr.
 then
$4380 $FFC0 opcode? if ." bics" 0 reg. 3 reg. then 
$BE00 $FF00 opcode? if ." bkpt" 0 imm8. then 
$4780 $FF87 opcode? if ." blx" 3 reg16. then 
$4700 $FF87 opcode? if ." bx" 3 reg16. then 
$42C0 $FFC0 opcode? if ." cmns" 0 reg. 3 reg. then 
$2800 $F800 opcode? if ." cmp" 8 reg. 0 imm8. then 
$4280 $FFC0 opcode? if ." cmp" 0 reg. 3 reg. then 
$4500 $FF00 opcode? if ." cmp" reg16split. 3 reg16. then 
$B660 $FFE8 opcode? if ." cps" 0 imm5. then 
$4040 $FFC0 opcode? if ." eors" 0 reg. 3 reg. then 
$C800 $F800 opcode? if ." ldmia" 8 reg. ."  {" registerlist. ." }" then 
$6800 $F800 opcode? if ." ldr" 0 reg. ."  [" 3 reg. 6 imm5<<2. ."  ]" then 
$5800 $FE00 opcode? if ." ldr" 0 reg. ."  [" 3 reg. 6 reg. ."  ]" then 
$4800 $F800 opcode? if ." ldr" 8 reg. ."  [ pc" 0 imm8<<2. ."  ]  Literal "
 dup $FF and shl shl ( Opcode Offset )
 disasm-$ @ 2+ 3 bic + ( Opcode Address )
 dup addr. ." : " @ addr. then
$9800 $F800 opcode? if ." ldr" 8 reg. ."  [ sp" 0 imm8<<2. ."  ]" then 
$7800 $F800 opcode? if ." ldrb" 0 reg. ."  [" 3 reg. 6 imm5. ."  ]" then 
$5C00 $FE00 opcode? if ." ldrb" 0 reg. ."  [" 3 reg. 6 reg. ."  ]" then 
$8800 $F800 opcode? if ." ldrh" 0 reg. ."  [" 3 reg. 6 imm5<<1. ."  ]" then
$5A00 $FE00 opcode? if ." ldrh" 0 reg. ."  [" 3 reg. 6 reg. ."  ]" then 
$5600 $FE00 opcode? if ." ldrsb" 0 reg. ."  [" 3 reg. 6 reg. ."  ]" then 
$5E00 $FE00 opcode? if ." ldrsh" 0 reg. ."  [" 3 reg. 6 reg. ."  ]" then 
$0000 $F800 opcode? if ." lsls" 0 reg. 3 reg. 6 imm5. then 
$4080 $FFC0 opcode? if ." lsls" 0 reg. 3 reg. then 
$0800 $F800 opcode? if ." lsrs" 0 reg. 3 reg. 6 imm5. then 
$40C0 $FFC0 opcode? if ." lsrs" 0 reg. 3 reg. then 
$2000 $F800 opcode? if ." movs" 8 reg. 0 imm8. then 
$1C00 $FFC0 opcode? if ." movs" 0 reg. 3 reg. then 
$4600 $FF00 opcode? if ." mov" reg16split. 3 reg16. then 
$4340 $FFC0 opcode? if ." muls" 0 reg. 3 reg. then 
$43C0 $FFC0 opcode? if ." mvns" 0 reg. 3 reg. then 
$4240 $FFC0 opcode? if ." negs" 0 reg. 3 reg. then 
$4300 $FFC0 opcode? if ." orrs" 0 reg. 3 reg. then 
$BC00 $FE00 opcode? if ." pop {" registerlist. dup $0100 and if ."  pc " then ." }" then
$B400 $FE00 opcode? if ." push {" registerlist. dup $0100 and if ."  lr " then ." }" then
$BA00 $FFC0 opcode? if ." rev" 0 reg. 3 reg. then 
$BA40 $FFC0 opcode? if ." rev16" 0 reg. 3 reg. then 
$BAC0 $FFC0 opcode? if ." revsh" 0 reg. 3 reg. then 
$41C0 $FFC0 opcode? if ." rors" 0 reg. 3 reg. then 
$4180 $FFC0 opcode? if ." sbcs" 0 reg. 3 reg. then 
$B650 $FFF7 opcode? if ." setend" then 
$C000 $F800 opcode? if ." stmia" 8 reg. ."  {" registerlist. ." }" then 
$6000 $F800 opcode? if ." str" 0 reg. ."  [" 3 reg. 6 imm5<<2. ."  ]" then 
$5000 $FE00 opcode? if ." str" 0 reg. ."  [" 3 reg. 6 reg. ."  ]" then 
$9000 $F800 opcode? if ." str" 8 reg. ."  [ sp + " 0 imm8<<2. ."  ]" then 
$7000 $F800 opcode? if ." strb" 0 reg. ."  [" 3 reg. 6 imm5. ."  ]" then 
$5400 $FE00 opcode? if ." strb" 0 reg. ."  [" 3 reg. 6 reg. ."  ]" then 
$8000 $F800 opcode? if ." strh" 0 reg. ."  [" 3 reg. 6 imm5<<1. ."  ]" then
$5200 $FE00 opcode? if ." strh" 0 reg. ."  [" 3 reg. 6 reg. ."  ]" then 
$1E00 $FE00 opcode? if ." subs" 0 reg. 3 reg. 6 imm3. then 
$3800 $F800 opcode? if ." subs" 8 reg. 0 imm8. then 
$1A00 $FE00 opcode? if ." subs" 0 reg. 3 reg. 6 reg. then 
$B080 $FF80 opcode? if ." sub sp" 0 imm7<<2. then 
$DF00 $FF00 opcode? if ." swi" 0 imm8. then 
$B240 $FFC0 opcode? if ." sxtb" 0 reg. 3 reg. then 
$B200 $FFC0 opcode? if ." sxth" 0 reg. 3 reg. then 
$4200 $FFC0 opcode? if ." tst" 0 reg. 3 reg. then 
$B2C0 $FFC0 opcode? if ." uxtb" 0 reg. 3 reg. then 
$B280 $FFC0 opcode? if ." uxth" 0 reg. 3 reg. then 
$BF00 $FF00 opcode? not if else 
 dup $000F and
 case
 $8 of ." it" endof
 over $10 and if else $8 xor then
 $C of ." itt" endof
 $4 of ." ite" endof
 over $10 and if else $4 xor then
 $E of ." ittt" endof
 $6 of ." itet" endof
 $A of ." itte" endof
 $2 of ." itee" endof
 over $10 and if else $2 xor then
 $F of ." itttt" endof
 $7 of ." itett" endof
 $B of ." ittet" endof
 $3 of ." iteet" endof
 $D of ." ittte" endof
 $5 of ." itete" endof
 $9 of ." ittee" endof
 $1 of ." iteee" endof
 endcase
 space
 dup $00F0 and 4 rshift condition.
 then
$E800 $F800 opcode? if disasm-thumb-2 then
$F000 $F000 opcode? if disasm-thumb-2 then
$2000 $FF00 opcode? if dup $FF and destination-r0 ! then
$3000 $FF00 opcode? if dup $FF and destination-r0 +! then
$0000 $F83F opcode? if destination-r0 @ 
 over $07C0 and 6 rshift lshift
 destination-r0 ! then
dup $4780 = if destination-r0 @ name. then 
drop
;
: memstamp
 dup u.8 ." : " h@ u.4 ."   " ;
: disasm-step ( -- )
 disasm-$ @ 
 dup memstamp disasm cr 
 begin
 2+ dup disasm-$ @ <>
 while
 dup memstamp cr
 repeat
 drop
;
: seec ( -- )
 base @ hex cr
 begin
 disasm-$ @ h@ $4770 = 
 disasm-$ @ h@ $FF00 and $BD00 = 
 or
 disasm-step
 until
 base !
;
: see ( -- )
 ' disasm-$ !
 seec
;
0 constant [struct 
: field 
 <builds over , + 
 does> @ + 
;
: struct] ( offset -- ) ( -- size ) constant ;
compiletoram
