module main

import regex

const (
	p_only_mnemonic                   = r'^[a-z]{3,4}$'
	p_only_mnemonic_literal           = r'^[a-z]{3,4} +(?:0[box])[a-f0-9]{1,16}$'
	p_only_mnemonic_register          = r'^[a-z]{3,4} +[abcdehl]$'
	p_only_mnemonic_register_literal  = r'^[a-z]{3,4} +[abcdehl],(?:0[box][a-f0-9]{1,16})$'
	p_only_mnemonic_register_register = r'^[a-z]{3,4} +[abcdehl],[abcdehl]$'

	p_prefix_mnemonic                 = r'^[a-z]{3,4}'

	register_names                    = map{
		Registers.a: 'a'
		Registers.b: 'b'
		Registers.c: 'c'
		Registers.d: 'd'
		Registers.e: 'e'
		Registers.h: 'h'
		Registers.l: 'l'
	}
)

enum Lines {
	mnemonic
	mnemonic_literal
	mnemonic_register
	mnemonic_register_literal
	mnemonic_register_register
}

enum Nodes {
	bare
	bare_u8
	bare_u16
	register
	register_u8
	register_u16
}

enum LiteralSize {
	size8
	size16
}

enum Registers {
	a
	b
	c
	d
	e
	h
	l
}

fn regex_matches(mut re regex.RE, value string) bool {
	start, stop := re.match_string(value)
	return start == 0 && stop == value.len
}

fn get_line_type(line string) ?Lines {
	mut mnemonic := regex.regex_opt(p_only_mnemonic) ?
	mut mnemonic_literal := regex.regex_opt(p_only_mnemonic_literal) ?
	mut mnemonic_register := regex.regex_opt(p_only_mnemonic_register) ?
	mut mnemonic_register_literal := regex.regex_opt(p_only_mnemonic_register_literal) ?
	mut mnemonic_register_register := regex.regex_opt(p_only_mnemonic_register_register) ?

	if regex_matches(mut mnemonic, line) {
		return Lines.mnemonic
	}
	if regex_matches(mut mnemonic_literal, line) {
		return Lines.mnemonic_literal
	}
	if regex_matches(mut mnemonic_register, line) {
		return Lines.mnemonic_register
	}
	if regex_matches(mut mnemonic_register_literal, line) {
		return Lines.mnemonic_register_literal
	}
	if regex_matches(mut mnemonic_register_register, line) {
		return Lines.mnemonic_register_register
	}

	return none
}

fn get_name(line string) ?string {
	mut re := regex.regex_opt(p_prefix_mnemonic) ?
	start, stop := re.match_string(line)
	if start == -1 {
		return none
	}

	return line[start..stop]
}

fn get_register(line string) ?Registers {
	// TODO
	return Registers.a
}

fn get_registers(line string) ?(Registers, Registers) {
	return Registers.a, Registers.b
}

fn get_literal_size(line string) ?LiteralSize {
	// TODO
	return LiteralSize.size8
}

fn get_u8literal(line string) ?U8Literal {
	// TODO
	return U8Literal{
		value: 0xff
	}
}

fn get_u16literal(line string) ?U16Literal {
	// TODO
	return U16Literal{
		value: 0xffff
	}
}

fn parse_line(line string) ?Node {
	line_type := get_line_type(line) ?

	match line_type {
		.mnemonic {
			return Instruction{
				name: get_name(line) ?
			}
		}
		.mnemonic_literal {
			literal_size := get_literal_size(line) ?
			match literal_size {
				.size8 {
					return InstructionU8{
						name: get_name(line) ?
						argument: get_u8literal(line) ?
					}
				}
				.size16 {
					return InstructionU16{
						name: get_name(line) ?
						argument: get_u16literal(line) ?
					}
				}
			}
		}
		.mnemonic_register {
			return InstructionRegister{
				name: get_name(line) ?
				register_target: register_names[get_register(line) ?]
			}
		}
		.mnemonic_register_literal {
			literal_size := get_literal_size(line) ?
			match literal_size {
				.size8 {
					return InstructionRegisterU8{
						name: get_name(line) ?
						register: register_names[get_register(line) ?]
						argument: get_u8literal(line) ?
					}
				}
				.size16 {
					return InstructionRegisterU16{
						name: get_name(line) ?
						register: register_names[get_register(line) ?]
						argument: get_u16literal(line) ?
					}
				}
			}
		}
		.mnemonic_register_register {
			target, source := get_registers(line) ?
			return InstructionRegisterRegister{
				name: get_name(line) ?
				register_target: register_names[target]
				register_source: register_names[source]
			}
		}
	}

	return none
}

fn lex(lines []string) []Node {
	mut nodes := []Node{}

	for line in lines {
		// println('will parse $line')
		// parsed := parse_line(line) or { panic(err) }
		// println(parsed)
		nodes << NodeEmpty{
			name: line
		}
	}
	//
	// for line in lines {
	// 	println(line)
	// 	nodes << parse_line(line) or {
	// 		panic(err)
	// 		return []
	// 	}
	// }

	return nodes
}
