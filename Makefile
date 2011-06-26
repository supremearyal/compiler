compiler: compiler.pas
	fpc compiler.pas

program: $(prog).asm
	nasm -f elf64 $(prog).asm
	tcc -o $(prog) $(prog).o
