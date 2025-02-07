extends Resource
class_name EnemyElementType


const ELEMENTS = preload("res://elements/elements.gd")

@export var element_type = ELEMENTS.ElementType.AIR
@export var spawning_ability: PackedScene


func _init(p_element_type = ELEMENTS.ElementType.AIR, p_spawning_ability = null):
	element_type = p_element_type
	spawning_ability = p_spawning_ability


func get_color():
	return ELEMENTS.get_color(element_type)
