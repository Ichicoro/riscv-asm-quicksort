#!/bin/bash
riscv64-unknown-elf-gdb \
-ex "tar rem :2323" \
-ex "display $a0" \
-ex "display $a2" \
-ex "display $a3" \
-ex "display $t5" \
-ex "display $s10" \
-ex "display $s11" \
quicksort