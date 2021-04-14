module main

const (
	argument_names = map{
		'-o':   'outfile'
		'-out': 'outfile'
	}

	flag_names     = map[string]string{}

	argument_count = map{
		'outfile': 1
	}
)

fn flag_receiver() map[string]bool {
	mut receiver := map[string]bool{}
	for _, name in flag_names {
		receiver[name] = false
	}

	return receiver
}

fn named_receiver() map[string][]string {
	mut receiver := map[string][]string{}
	for key, size in argument_count {
		receiver[key] = []string{len: 0, cap: size}
	}

	return receiver
}

// TODO use an enum to represent this
// so that the entire thing is on the stack
fn parse_arguments(read []string) ([]string, map[string]bool, map[string][]string) {
	mut arguments := []string{cap: read.len}
	mut flags := flag_receiver()
	mut named := named_receiver()

	mut index := 0
	for index != read.len {
		current := read[index]

		if current.starts_with('-') {
			if current in argument_names {
				name := argument_names[current]
				index++

				if argument_count[name] != -1 && named[name].len >= argument_count[name] {
					panic('Already have $argument_count[arg_name] for $name ( $current )')
				}

				if read.len == index || read[index].starts_with('-') {
					panic('No value provided for $name ( $current )')
				}

				named[name] << read[index]
			} else if current in flag_names {
				flags[flag_names[current]] = true
			} else {
				panic("I don't know what $current is")
			}
		} else {
			arguments << current
		}

		index++
	}

	return arguments, flags, named
}
