extends Resource
class_name ability_data_resource

enum ElementalType {
	AIR = 100,
	FIRE = 200,
	WATER = 300,
}

const COLOR_AIR = Color("#dbdbdb")
const COLOR_PLAIN = Color("#949494")
const COLOR_FIRE = Color("#b05a5a")
const COLOR_WATER = Color("#5a8cb0")

const ENEMY_SCRIPT = preload("res://enemies/enemy.gd")

@export var color : Color
@export var ability_scene: PackedScene
@export var elemental_type : ElementalType
@export var walking_speed := 15
@export var flying_speed := 10

func _init():
	color = COLOR_AIR
	elemental_type = ElementalType.AIR
