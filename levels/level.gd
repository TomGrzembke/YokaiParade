extends Node2D


func _ready() -> void:
	var player_scene = preload("res://player/player.tscn")
	
	var player = player_scene.instantiate()
	player.transform = $PlayerSpawnPoint.transform
	
	get_parent().add_child.call_deferred(player)
