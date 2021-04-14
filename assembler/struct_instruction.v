module main

struct Instruction {
	name  string
	width int = 1
}

fn (node Instruction) opcode() byte {
	assert false
	return 0
}

fn (node Instruction) arguments() []byte {
	return []
}
