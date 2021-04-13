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
	if rom.len > 0xffff {
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

fn (mut state State) set_acarry(value byte) {
	state.acarry = value >> 4 & 1 == 1
}

fn (mut state State) set_zero(value byte) {
	state.zero = value == 0
}

fn (mut state State) execute() {
	mut pc := 0
	for pc != 0xffff {
		match state.rom[pc] {
			0x00, 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38 {}
			lxi_b {
				state.b = state.rom[pc + 2]
				state.c = state.rom[pc + 1]
				pc += 2
			}
			stax_b {
				state.b = state.a >> 8
				state.c = state.a & 0xff
			}
			inx_b {
				result := 1 + join(state.b, state.c)
				state.b = byte(result >> 8)
				state.c = byte(result & 0xff)
			}
			inr_b {
				state.b++
				state.set_acarry(state.b)
				state.set_zero(state.b)
			}
			dcr_b {
				state.b--
				state.set_acarry(state.b)
				state.set_zero(state.b)
			}
			mvi_b {
				state.b = state.rom[pc + 1]
				pc++
			}
			rlc {
				state.acarry = 1 == state.a >> 7
				state.a = (state.a << 1) | byte(state.acarry)
			}
			dad_b {
				hl := join(state.h, state.l) + join(state.b, state.c)
				state.h = byte(hl >> 8)
				state.l = byte(hl & 0xff)
			}
			sta {
				state.ram[join(state.rom[pc + 2], state.rom[pc + 1])] = state.a
				pc += 2
			}
			lda {
				state.a = state.ram[join(state.rom[pc + 2], state.rom[pc + 1])]
				pc += 2
			}
			inr_a {
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
	print('b  $state.b\tc  $state.c\td  $state.d\tac ${x_if(state.acarry)}\tc  ${x_if(state.carry)}\n')
	print('e  $state.e\th  $state.h\tl  $state.l\tp  ${x_if(state.parity)}\ts  ${x_if(state.sign)}\tz  ${x_if(state.zero)}\n')

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
