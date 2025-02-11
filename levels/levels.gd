extends Node


@export var levels: Array[PackedScene]

var current_level = null


func get_number_of_levels():
	return levels.size()


func set_current_level(new_level):
	if current_level != null:
		current_level.queue_free()

	current_level = new_level

	add_child.call_deferred(current_level)


func load_level(level_index):
	var success = false

	if level_index < levels.size() \
	and levels[level_index] != null:
		var level = levels[level_index].instantiate()
		set_current_level(level)
		success = true

	return success


func get_player_spawn_position_of_level():
	if current_level == null:
		printerr("Error: Current level not set!")
		return null

	if current_level.get_player_spawn_position() == null:
		printerr("Error: Level is missing PlayerSpawnPoint!")

	return current_level.get_player_spawn_position()
