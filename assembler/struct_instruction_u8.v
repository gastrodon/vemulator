module main

struct InstructionU8 {
	name     string
	argument U8Literal
	width    int = 2
}

fn (node InstructionU8) opcode() byte {
	assert false
	return 0
}

fn (node InstructionU8) arguments() []byte {
	return node.argument.bytes()
}
