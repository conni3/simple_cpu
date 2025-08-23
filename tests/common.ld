ENTRY(_start)
SECTIONS
{
  . = 0x00000000;
  .text : { *(.text*) *(.rodata*) }
  . = ALIGN(4);
  .data : { *(.data*) *(.sdata*) }
  .bss  : { *(.bss*)  *(.sbss*)  *(COMMON) }
}
