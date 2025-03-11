extends Node2D


@export var entity: Node2D

var did_take_damage = false


func _ready():
	assert(get_node_or_null("TakeDamageArea") != null, "Take damage component at %s is missing TakeDamageArea child." % get_path())

	entity.enemy_caught.connect(on_enemy_caught)


func get_did_take_damage():
	return did_take_damage


func set_did_take_damage(positive):
	did_take_damage = positive

	set_take_damage_active(not positive)


func set_take_damage_active(active):
	$TakeDamageArea.set_deferred("monitorable", active)


func on_enemy_caught(_enemy):
	set_did_take_damage(true)
