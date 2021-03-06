module main

fn test_nop() {
	mut state := State{}
	state.load([byte(nop), 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38]) or { assert false }
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
	state.load([byte(lxi_b), 0xdd, 0xff]) or { assert false }
	state.execute()

	assert state.b == 0xff
	assert state.c == 0xdd
	assert join(state.b, state.c) == 0xffdd
}

fn test_stax_b() {
	mut state := State{}
	state.load([byte(inr_a), inr_a, stax_b]) or { assert false }
	state.execute()

	assert state.b == 0
	assert state.c == 0x02
}

fn test_inx_b() {
	mut state := State{}
	state.load([byte(inx_b), inx_b, inx_b]) or { assert false }
	state.execute()

	assert state.b == 0
	assert state.c == 0x03
}

fn test_inr_b() {
	mut state := State{}
	state.load([byte(inr_b)]) or { assert false }
	state.execute()

	assert state.b == 0x01
	assert !state.acarry
	assert !state.zero
}

fn test_inr_b_zero() {
	mut state := State{
		b: 0xff
	}
	state.load([byte(inr_b)]) or { assert false }
	state.execute()

	assert state.b == 0
	assert !state.acarry
	assert state.zero
}

fn test_inr_b_acarry() {
	mut state := State{
		b: 0b00001111
	}
	state.load([byte(inr_b)]) or { assert false }
	state.execute()

	assert state.b == 0b00010000
	assert state.acarry
	assert !state.zero
}

fn test_inr_b_sign() {
	mut state := State{
		b: 0x7f
	}
	state.load([byte(inr_b)]) or { assert false }
	state.execute()

	assert state.b == 0x80
	assert state.sign

	state = State{}
	state.load([byte(inr_b)]) or { assert false }
	state.execute()

	assert state.b == 1
	assert !state.sign
}

fn test_inr_b_parity() {
	mut state := State{
		b: 0b10
	}
	state.load([byte(inr_b)]) or { assert false }
	state.execute()

	assert state.b == 0b11
	assert state.parity

	state = State{}
	state.load([byte(inr_b)]) or { assert false }
	state.execute()

	assert state.b == 1
	assert !state.parity
}

fn test_dcr_b() {
	mut state := State{}
	state.load([byte(dcr_b)]) or { assert false }
	state.execute()

	assert state.b == 0xff
	assert !state.carry
}

fn test_dcr_b_zero() {
	mut state := State{
		b: 0x01
	}
	state.load([byte(dcr_b)]) or { assert false }
	state.execute()

	assert state.b == 0
	assert state.zero
	assert !state.acarry
}

fn test_dcr_b_acarry() {
	mut state := State{
		b: 0b00100000
	}
	state.load([byte(dcr_b)]) or { assert false }
	state.execute()

	assert state.b == 0b000011111
	assert !state.zero
	assert state.acarry
}

fn test_dcr_b_sign() {
	mut state := State{}
	state.load([byte(dcr_b)]) or { assert false }
	state.execute()

	assert state.b == 0xff
	assert state.sign

	state = State{
		b: 0x7f
	}
	state.load([byte(dcr_b)]) or { assert false }
	state.execute()

	assert state.b == 0x7e
	assert !state.sign
}

fn test_dcr_b_parity() {
	mut state := State{
		b: 0b100
	}
	state.load([byte(dcr_b)]) or { assert false }
	state.execute()

	assert state.b == 0b11
	assert state.parity

	state = State{
		b: 0b11
	}
	state.load([byte(dcr_b)]) or { assert false }
	state.execute()

	assert state.b == 2
	assert !state.parity
}

fn test_mvi_b_d8() {
	mut state := State{}
	state.load([byte(mvi_b), 0xcc]) or { assert false }
	state.execute()

	assert state.b == 0xcc
}

fn test_rlc() {
	mut state := State{
		a: 0x01
	}

	state.load([byte(rlc)]) or { assert false }
	state.execute()

	assert state.a == 0x02
	assert !state.carry
}

fn test_rlc_acarry() {
	mut state := State{
		a: 0b10000000
	}

	state.load([byte(rlc)]) or { assert false }
	state.execute()

	assert state.a == 0b00000001
	assert state.carry
}

fn test_dad_b() {
	mut state := State{
		b: 0x22
		c: 0x22
		h: 0xcc
		l: 0xff
	}

	state.load([byte(dad_b)]) or { assert false }
	state.execute()

	mut target := 0xccff + 0x2222
	assert join(state.h, state.l) == target
	assert state.h == target >> 8
	assert state.l == target & 0xff
	assert !state.carry

	state = State{
		b: 0xff
		c: 0xff
		h: 0xcc
		l: 0xff
	}

	state.load([byte(dad_b)]) or { assert false }
	state.execute()

	target = 0xccfe
	assert join(state.h, state.l) == target
	assert state.h == target >> 8
	assert state.l == target & 0xff
	assert state.carry
}

fn test_sta_a16() {
	mut state := State{}
	state.load([byte(inr_a), 0x3c, 0x32, dcr_b, nop]) or { assert false }
	state.execute()

	assert state.ram[0x05] == 2
}

fn test_inr_a() {
	mut state := State{}
	state.load([byte(inr_a), 0x3c, 0x3c]) or { assert false }
	state.execute()

	assert state.a == 3
}
