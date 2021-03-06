\ DAC Signal generation

\ Requires:

$4004802C constant SIM_SCGC2            \ System Clock Gating Control Register 2
$00001000 constant SIM_SCGC2_DAC0       \ DAC0 Clock Gate Control


$400CC000 constant DAC0_DAT0L  \ DAC Data Low Register
$400CC001 constant DAC0_DAT0H  \ DAC Data High Register
$400CC002 constant DAC0_DAT1L  \ DAC Data Low Register
$400CC004 constant DAC0_DAT2L  \ DAC Data Low Register
$400CC006 constant DAC0_DAT3L  \ DAC Data Low Register
$400CC008 constant DAC0_DAT4L  \ DAC Data Low Register
$400CC00A constant DAC0_DAT5L  \ DAC Data Low Register
$400CC00C constant DAC0_DAT6L  \ DAC Data Low Register
$400CC00E constant DAC0_DAT7L  \ DAC Data Low Register
$400CC010 constant DAC0_DAT8L  \ DAC Data Low Register
$400CC012 constant DAC0_DAT9L  \ DAC Data Low Register
$400CC014 constant DAC0_DAT10L \ DAC Data Low Register
$400CC016 constant DAC0_DAT11L \ DAC Data Low Register
$400CC018 constant DAC0_DAT12L \ DAC Data Low Register
$400CC01A constant DAC0_DAT13L \ DAC Data Low Register
$400CC01C constant DAC0_DAT14L \ DAC Data Low Register
$400CC01E constant DAC0_DAT15L \ DAC Data Low Register
$400CC020 constant DAC0_SR     \ DAC Status Register
$400CC021 constant DAC0_C0     \ DAC Control Register
  $80 constant DAC_C0_DACEN               \ DAC Enable
  $40 constant DAC_C0_DACRFS              \ DAC Reference Select
$400CC022 constant DAC0_C1     \ DAC Control Register 1
  $1 constant DAC_C1_DACBFEN              \ DAC Reference Select
  $80 constant DAC_C1_DMAEN              \ DAC Reference Select
$400CC023 constant DAC0_C2     \ DAC Control Register 2

: dac ( u -- )  \ 0 - 4095
  DAC0_DAT0L h! ( val -- )
 ;

: +dac ( -- ) \ dac0 init
  SIM_SCGC2_DAC0              SIM_SCGC2 bis!

\  DAC_C1_DACBFEN                DAC0_C1 c! \ Disable for DMA
  DAC_C0_DACEN DAC_C0_DACRFS or DAC0_C0 c!
  0 dac
 ;


