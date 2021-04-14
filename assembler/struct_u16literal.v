module main

struct U16Literal {
	value u16
}

fn (literal U16Literal) bytes() []byte {
	return [byte(literal.value & 0xff), byte(literal.value >> 8)]
}
