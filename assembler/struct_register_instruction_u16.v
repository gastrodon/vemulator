module main

struct InstructionRegisterU16 {
	name     string
	register string
	argument U16Literal
	width    int = 3
}

fn (node InstructionRegisterU16) opcode() byte {
	assert false
	return 0
}

fn (node InstructionRegisterU16) arguments() []byte {
	return node.argument.bytes()
}
