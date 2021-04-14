module main

interface Literal {
	bytes() []byte
}

interface Node {
	name string
	opcode() byte
	arguments() []byte
}

struct NodeEmpty {
	name string
}

fn (node NodeEmpty) opcode() byte {
	return 0
}

fn (node NodeEmpty) arguments() []byte {
	return [byte(0)]
}
