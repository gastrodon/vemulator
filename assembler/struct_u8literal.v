module main

struct U8Literal {
	value byte
}

fn (literal U8Literal) bytes() []byte {
	return [literal.value]
}
