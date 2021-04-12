module main

fn test_state_pc() {
	mut state := State{}

	assert state.pc == 0

	state.execute()

	assert state.pc == 0xFFFF
}
