module main

fn join(high byte, low byte) u16 {
	return (u16(high) << 8) | u16(low)
}
