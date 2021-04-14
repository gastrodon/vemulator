module main

struct InstructionRegisterU8 {
	name     string
	register string
	argument U8Literal
	width    int = 2
}

fn (node InstructionRegisterU8) opcode() byte {
	assert false
	return 0
}

fn (node InstructionRegisterU8) arguments() []byte {
	return node.argument.bytes()
}
