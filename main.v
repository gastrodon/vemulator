module main

struct State {
mut:
	ram [255]byte
	// sign
	// zero
	// 0 literal
	// aux carry
	// 0 literal
	// parity
	// 1 literal
	// carry
	flags byte = 0b00000010

	a  byte
	b  byte
	c  byte
	d  byte
	e  byte
	h  byte
	l  byte
	sp u16
	pc u16
}

fn (mut state State) execute(rom []byte) {
	rom_length := rom.len
	if rom_length > 1 << 16 - 1 {
		println('rom length must be countable by u16')
		return
	}

	mut pc := 0
	for pc != rom_length {
		match rom[pc] {
			// NOP
			0x00, 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38 {}
			// LXI B d16
			0x01 {
				state.b = rom[pc + 2]
				state.c = rom[pc + 1]
				pc += 2
			}
			// STAX B
			0x02 {
				state.b = state.a >> 8
				state.c = state.a & 0xFF
			}
			// INX B
			0x03 {
				// TODO flags
				state.b++
			}
			0x04 {
				// TODO flags
				state.b--
			}
			// STA a16
			0x32 {
				address := u16(rom[pc + 2]) << 8 | u16(rom[pc + 1])
				state.ram[address] = byte(state.a)
				pc += 2
			}
			// LDA a16
			0x3a {
				state.a = state.ram[int(rom[pc + 2]) << 8 | int(rom[pc + 1])]
				pc += 2
			}
			// INR A
			0x3c {
				state.a++
			}
			else {}
		}

		pc++
	}

	state.pc = u16(pc)
}

fn (state State) print() {
	print('a  $state.a\t')
	print('sp $state.sp\t')
	print('pc $state.pc \n')
	print('b  $state.b\t')
	print('c  $state.c\t')
	print('d  $state.d \n')
	print('e  $state.e\t')
	print('h  $state.h\t')
	print('l  $state.l \n')

	print('\nmem  | ')

	prefix := ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f']
	for fix in prefix {
		print(' $fix ')
	}

	width := 16
	height := state.ram.len / 16

	for line in 0 .. height {
		print('\n0x${prefix[line]}0 | ')

		for cell in state.ram[line * width..line * width + width] {
			print(' $cell ')
		}
	}

	println('')
}

fn main() {
	mut state := State{}

	// state.execute([byte(0x10), byte(0x3c), byte(0x00), byte(0x32), byte(0x7)])
	state.execute([
		// INR A
		byte(0x3c),
		// INR A
		0x3c,
		// INR A
		0x3c,
		// STA
		0x32,
		0x05,
		0x00,
	])
	state.print()
}
