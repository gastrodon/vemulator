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
	state.acarry = (value & 0x10) == 0x10
}

fn (mut state State) set_parity(value byte) {
	state.parity = even_parity(value)
}

fn (mut state State) set_sign(value byte) {
	state.sign = (value & 0x80) == 0x80
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
				state.set_parity(state.b)
				state.set_sign(state.b)
				state.set_zero(state.b)
			}
			dcr_b {
				state.b--
				state.set_acarry(state.b)
				state.set_parity(state.b)
				state.set_sign(state.b)
				state.set_zero(state.b)
			}
			mvi_b {
				state.b = state.rom[pc + 1]
				pc++
			}
			rlc {
				state.a, state.carry = shift_left_wrap_carry(state.a)
			}
			dad_b {
				hl, carry := add_carry_u16(join(state.h, state.l), join(state.b, state.c))
				state.carry = carry
				state.h = byte(hl >> 8)
				state.l = byte(hl & 0xff)
			}
			else {}
		}

		pc++
	}

	state.pc = u16(pc)
}

fn (state State) print() {
	print('a  0x${state.a:x}\tsp 0x${state.sp:x}\tpc 0x${state.pc:x}\n')
	print('b  0x${state.b:x}\tc  0x${state.c:x}\td  0x${state.d:x}\tac ${x_if(state.acarry)}\tc  ${x_if(state.carry)}\n')
	print('e  0x${state.e:x}\th  0x${state.h:x}\tl  0x${state.l:x}\tp  ${x_if(state.parity)}\ts  ${x_if(state.sign)}\tz  ${x_if(state.zero)}\n')

	width := 16
	height := state.ram.len / 16
	prefix := ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f']
	for line in 0 .. height {
		print('\n0x${prefix[line]}0 | ')

		for cell in state.ram[line * width..line * width + width] {
			print(' ${cell:x} ')
		}
	}

	println('')
}
