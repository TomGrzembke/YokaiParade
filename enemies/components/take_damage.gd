extends Node2D


@export var entity: Node2D


var did_take_damage = false


func _ready():
	assert(get_node_or_null("TakeDamageArea") != null, "Take damage component at %s is missing TakeDamageArea child." % get_path())


func get_did_take_damage():
	return did_take_damage


func set_did_take_damage(positive):
	did_take_damage = positive


func got_caught(_source):
	if did_take_damage: return

	set_did_take_damage(true)

	if entity.element_type == null:
		return null
	return entity.element_type.spawning_ability
