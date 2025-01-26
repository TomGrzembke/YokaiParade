extends Node2D


func get_player_spawn_position():
	return $PlayerSpawnPoint.global_position


func set_player_spawn_position(new_position):
	if get_node_or_null("PlayerSpawnPoint") != null:
		$PlayerSpawnPoint.global_position = new_position
	else:
		printerr("Error: No PlayerSpawnPoint in this level!")
