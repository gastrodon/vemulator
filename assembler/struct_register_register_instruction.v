module main

struct InstructionRegisterRegister {
	name            string
	register_target string
	register_source string
	width           int = 1
}

fn (node InstructionRegisterRegister) opcode() byte {
	assert false
	return 0
}

fn (node InstructionRegisterRegister) arguments() []byte {
	return []
}
