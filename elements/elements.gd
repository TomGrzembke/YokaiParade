extends Object


enum ElementType {
	AIR = 100,
	FIRE = 200,
}


const COLOR_MAP = {
	ElementType.AIR: Color("#dbdbdb"),
	ElementType.FIRE: Color("#b05a5a"),
}


static func get_color(element_type):
	return COLOR_MAP[element_type]
