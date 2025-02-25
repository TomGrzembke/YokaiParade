extends Resource


enum ElementType {
	AIR = 100,
	FIRE = 200,
}


const COLOR_MAP = {
	ElementType.AIR: Color("#2cc8bc"),
	ElementType.FIRE: Color("#f12e17"),
}


static func get_color(element_type):
	return COLOR_MAP[element_type]
