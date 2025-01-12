extends Node


signal level_loaded(player_spawn_position)


@export var levels: Array[PackedScene]


var _current_level = null:
	set = _set_current_level

var number_of_levels:
	get:
		return levels.size()


func _set_current_level(new_value):
	if _current_level != null:
		_current_level.queue_free()

	_current_level = new_value

	add_child(_current_level)


func load_level(level_index) -> bool:
	var success = false

	if level_index < levels.size() \
	and levels[level_index] != null:
		var level = levels[level_index].instantiate()
		_current_level = level
		var player_spawn_position = level.player_spawn_position
		if player_spawn_position != null:
			level_loaded.emit(player_spawn_position)
		else:
			print("Player spawn position for level not found!")
		success = true

	return success
