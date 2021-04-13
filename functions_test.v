module main

fn test_join() {
	assert join(0xdd, 0xff) == 0xddff
}

fn test_add_carry() {
	mut result, mut carry := add_carry(0xff, 1)
	assert result == 0
	assert carry

	result, carry = add_carry(1, 1)
	assert result == 2
	assert !carry

	result, carry = add_carry(100, 0)
	assert result == 100
	assert !carry
}

fn test_sub_carry() {
	mut result, mut carry := sub_carry(0, 1)
	assert result == 0xff
	assert carry

	result, carry = sub_carry(1, 1)
	assert result == 0
	assert !carry

	result, carry = sub_carry(100, 0)
	assert result == 100
	assert !carry
}

fn test_even_parity() {
	assert even_parity(0b1) == false
	assert even_parity(0b10) == false
	assert even_parity(0b100) == false
	assert even_parity(0b1000) == false
	assert even_parity(0b1101) == false

	assert even_parity(0b11) == true
	assert even_parity(0b110) == true
	assert even_parity(0b1100) == true
	assert even_parity(0b110011) == true
}

fn test_x_if() {
	assert x_if(true) == 'x'
	assert x_if(false) == '_'
}
