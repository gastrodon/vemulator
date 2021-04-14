module main

struct InstructionU16 {
	name     string
	argument U16Literal
	width    int = 3
}

fn (node InstructionU16) opcode() byte {
	assert false
	return 0
}

fn (node InstructionU16) arguments() []byte {
	return node.argument.bytes()
}
