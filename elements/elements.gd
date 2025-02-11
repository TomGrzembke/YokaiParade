extends Object


enum ElementType {
	AIR = 100,
	FIRE = 200,
}


const COLOR_MAP = {
	ElementType.AIR: Color("#9900ff"),
	ElementType.FIRE: Color("#fc0042"),
}


static func get_color(element_type):
	return COLOR_MAP[element_type]
