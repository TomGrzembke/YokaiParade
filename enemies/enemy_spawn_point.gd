extends Node2D


@export var enemy_scene: PackedScene
@export_range(0.0, 10.0, 0.1) var respawn_wait_time = 1.0


func _ready():
	spawn_enemy()


func spawn_enemy():
	if enemy_scene == null:
		print("No enemy scene configured in spawn point!")
		return
	var enemy = enemy_scene.instantiate()
	enemy.enemy_died.connect(start_delayed_respawn)
	add_child(enemy)


func start_delayed_respawn():
	if !%Timer.is_stopped():
		%Timer.stop()
	%Timer.wait_time = respawn_wait_time
	%Timer.start()
