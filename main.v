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
	bc u16
	de u16
	hl u16 // Also m
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
				state.bc = u16(rom[pc + 2]) << 8 | u16(rom[pc + 1])
				pc += 2
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
	print('a  $state.a ')
	print('bc $state.bc ')
	print('de $state.de \n')
	print('hl $state.hl ')
	print('sp $state.sp ')
	print('pc $state.pc \n')

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
