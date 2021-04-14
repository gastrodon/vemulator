module main

import os

fn main() {
	arguments, _, _ := parse_arguments(os.args_after('')[1..])

	lines := clean(read_all(arguments))
	lexed := lex(lines)
	println(lexed)
}
