extends Node2D


func _ready():
	_spawn_player()


func _spawn_player():
	var player_scene = preload("res://player/player.tscn")

	var player = player_scene.instantiate()
	player.transform = $PlayerSpawnPoint.transform
	player.player_despawned.connect(_on_player_despawn)

	var camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 10.0

	player.add_child(camera)

	get_parent().add_child.call_deferred(player)


func _unhandled_input(_event):
	if Input.is_action_just_pressed("reset_level"):
		_reload_level()


func _on_despawn_area_body_entered(body):
	if body.has_method("despawn"):
		body.despawn()


func _on_player_despawn():
	_reload_level()


func _reload_level():
	get_tree().call_deferred("reload_current_scene")
