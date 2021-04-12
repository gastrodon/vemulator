module main

struct State {
mut:
	ram [255]byte
	rom [65535]byte // TODO make this immutable with a constructor?

	acarry bool
	carry  bool
	parity bool
	sign   bool
	zero   bool

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

// load will take some bytes and load it into the machine's rom
// the number of bytes written is returned, or none
fn (mut state State) load(rom []byte) ?u16 {
	if rom.len > 0xFFFF {
		println('ROM must be indexable by u16')
		return none
	}

	mut index := u16(0)
	mut buffer := [0xffff]byte{}
	for code in rom {
		buffer[index] = code
		index++
	}

	state.rom = buffer
	return index
}

fn (mut state State) execute() {
	mut pc := 0
	for pc != 0xffff {
		match state.rom[pc] {
			// NOP
			0x00, 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38 {}
			// LXI B d16
			0x01 {
				state.b = state.rom[pc + 2]
				state.c = state.rom[pc + 1]
				pc += 2
			}
			// STAX B
			0x02 {
				state.b = state.a >> 8
				state.c = state.a & 0xFF
			}
			// INX B
			0x03 {
				result := 1 + u16(state.b) << 8 | u16(state.c)
				state.b = byte(result >> 8)
				state.c = byte(result & 0xFF)
			}
			// INR B
			0x04 {
				// TODO flags
				state.b++
			}
			// DCR B
			0x05 {
				// TODO flags
				state.b--
			}
			// MVI B d8
			0x06 {
				state.b = state.rom[pc + 1]
				pc++
			}
			// STA a16
			0x32 {
				address := u16(state.rom[pc + 2]) << 8 | u16(state.rom[pc + 1])
				state.ram[address] = byte(state.a)
				pc += 2
			}
			// LDA a16
			0x3a {
				state.a = state.ram[int(state.rom[pc + 2]) << 8 | int(state.rom[pc + 1])]
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
	print('a  $state.a\tsp $state.sp\tpc $state.pc\n')
	print('b  $state.b\tc  $state.c\td  $state.d \n')
	print('e  $state.e\th  $state.h\tl  $state.l \n')

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

	state.load([
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
	]) or { panic('no bytes were written') }

	state.execute()
	state.print()
}
