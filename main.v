module main

import os

fn main() {
	rom := os.read_bytes('./rom.bin') or { panic('failed to read ./rom.bin') }
	mut state := State{}

	state.load(rom) or { panic('failed to load ./rom.bin') }
	state.execute()
	state.print()
}
