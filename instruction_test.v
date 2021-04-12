module main

fn test_nop() {
	mut state := State{}
	state.load([byte(0x00), 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38]) or { assert false }
	state.execute()

	fresh := State{}
	assert state.ram == fresh.ram

	assert state.a == 0
	assert state.b == 0
	assert state.c == 0
	assert state.d == 0
	assert state.e == 0
	assert state.h == 0
	assert state.l == 0
	assert state.sp == 0
}

fn test_lxi_b() {
	mut state := State{}
	state.load([byte(0x01), 0xdd, 0xff]) or { assert false }
	state.execute()

	assert state.b == 0xff
	assert state.c == 0xdd
	assert join(state.b, state.c) == 0xffdd
}

fn test_stax_b() {
	mut state := State{}
	state.load([byte(0x3c), 0x3c, 0x02]) or { assert false }
	state.execute()

	assert state.b == 0
	assert state.c == 0x02
}

fn test_inx_b() {
	mut state := State{}
	state.load([byte(0x03), 0x03, 0x03]) or { assert false }
	state.execute()

	assert state.b == 0
	assert state.c == 0x03
}

fn test_inr_b() {
	mut state := State{}
	state.load([byte(0x04)]) or { assert false }
	state.execute()

	assert state.b == 0x01
	assert !state.carry
}

fn test_dcr_b() {
	mut state := State{}
	state.load([byte(0x05)]) or { assert false }
	state.execute()

	assert state.b == 0xff
	assert !state.carry
}

fn test_mvi_b_d8() {
	mut state := State{}
	state.load([byte(0x06), 0xcc]) or { assert false }
	state.execute()

	assert state.b == 0xcc
}

fn test_rlc() {
	mut state := State{
		a: 0x01
	}

	state.load([byte(0x07)]) or { assert false }
	state.execute()

	assert state.a == 0x02
}

fn test_rlc_acarry() {
	mut state := State{
		a: 0b10000000
	}

	state.load([byte(0x07)]) or { assert false }
	state.execute()

	assert state.a == 0b00000001
}

fn test_dad_b() {
	mut state := State{
		b: 0x22
		c: 0x22
		h: 0xcc
		l: 0xff
	}

	state.load([byte(0x09)]) or { assert false }
	state.execute()

	target := 0xccff + 0x2222
	assert join(state.h, state.l) == target
	assert state.h == target >> 8
	assert state.l == target & 0xff
}

fn test_sta_a16() {
	mut state := State{}
	state.load([byte(0x3c), 0x3c, 0x32, 0x05, 0x00]) or { assert false }
	state.execute()

	assert state.ram[0x05] == 2
}

fn test_inr_a() {
	mut state := State{}
	state.load([byte(0x3c), 0x3c, 0x3c]) or { assert false }
	state.execute()

	assert state.a == 3
}
