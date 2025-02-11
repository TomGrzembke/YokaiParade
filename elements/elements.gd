extends Object


enum ElementType {
	AIR = 100,
	FIRE = 200,
}


const COLOR_MAP = {
	ElementType.AIR: Color("#9900ff"),
	ElementType.FIRE: Color("#e4673b"),
}


static func get_color(element_type):
	return COLOR_MAP[element_type]
