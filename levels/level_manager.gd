extends Node


signal level_loaded(player_spawn_position)


@export var levels: Array[PackedScene]


var player_spawn_position = null
var current_level = null


func get_number_of_levels():
	return levels.size()


func set_current_level(new_level):
	if current_level != null:
		current_level.queue_free()

	current_level = new_level

	add_child.call_deferred(current_level)


func load_level(level_index) -> bool:
	var success = false

	if level_index < levels.size() \
	and levels[level_index] != null:
		var level = levels[level_index].instantiate()
		set_current_level(level)

		if player_spawn_position == null:
			player_spawn_position = level.player_spawn_position
		if player_spawn_position == null:
			print("Level is missing PlayerSpawnPoint!")
		else:
			current_level.set_player_spawn_position(player_spawn_position)
			level_loaded.emit(player_spawn_position)
			success = true

	return success


func set_player_spawn_position(position):
	player_spawn_position = position
