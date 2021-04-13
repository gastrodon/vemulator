module main

fn join(high byte, low byte) u16 {
	return (u16(high) << 8) | u16(low)
}

fn add_carry(value byte, diff byte) (byte, bool) {
	if diff == 0 {
		return value, false
	}

	result := value + diff
	return result, result < value
}

fn sub_carry(value byte, diff byte) (byte, bool) {
	if diff == 0 {
		return value, false
	}

	result := value - diff
	return result, result > value
}

fn even_parity(value byte) bool {
	mut result := true
	if value == 0 {
		return result
	}

	mut shift := 0
	for shift != 7 {
		shifted := value >> shift
		if shifted == 0 {
			break
		}

		if shifted & 1 == 1 {
			result = !result
		}

		shift++
	}

	return result
}

fn x_if(value bool) string {
	if value {
		return 'x'
	} else {
		return '_'
	}
}
