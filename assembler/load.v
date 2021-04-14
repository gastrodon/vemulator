module main

import os

fn read_all(filenames []string) []string {
	mut read := []string{}

	for name in filenames {
		if lines := os.read_lines(name) {
			read << lines
		} else {
			panic(err)
		}
	}

	return read
}

fn clean(lines []string) []string {
	return lines.map(it.before(';').trim(' ')).filter(it != '')
}
