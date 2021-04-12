module main

fn join(high byte, low byte) u16 {
	return (u16(high) << 8) | u16(low)
}

fn x_if(value bool) string {
	if value {
		return 'x'
	} else {
		return '_'
	}
}
