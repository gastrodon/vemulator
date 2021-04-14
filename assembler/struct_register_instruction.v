module main

struct InstructionRegister {
	name            string
	register_target string
	width           int = 1
}

fn (node InstructionRegister) opcode() byte {
	assert false
	return 0
}

fn (node InstructionRegister) arguments() []byte {
	return []
}
