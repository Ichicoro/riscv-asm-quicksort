riscv64-unknown-elf-as -g -o main.o main.S
riscv64-unknown-elf-as -g -o quicksort.o quicksort.S
riscv64-unknown-elf-as -g -o itoa.o itoa.S
riscv64-unknown-elf-ld -o quicksort main.o quicksort.o itoa.o
rm -r *.o
