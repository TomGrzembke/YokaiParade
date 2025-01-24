extends Node2D


var player_spawn_position:
	get:
		return $PlayerSpawnPoint.global_position


func set_player_spawn_position(new_position):
	if $PlayerSpawnPoint != null:
		$PlayerSpawnPoint.global_position = new_position
	else:
		print("Error: No PlayerSpawnPoint in this level!")


func _on_despawn_area_body_entered(body):
	if body.has_method("despawn"):
		body.despawn()
