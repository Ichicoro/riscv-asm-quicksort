riscv64-unknown-elf-as -g -o quicksort.o quicksort.S
riscv64-unknown-elf-as -g -o itoa.o itoa.S
riscv64-unknown-elf-ld -o quicksort quicksort.o itoa.o
rm -r *.o
