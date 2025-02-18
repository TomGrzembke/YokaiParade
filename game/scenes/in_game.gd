extends GameStateScene


var current_level_index = 0
var player_spawn_position = null
var is_play_timer_running = false
var play_time = 0.0


func _ready():
	load_level(0)
	spawn_player()
	start_timer()


func _process(delta):
	if is_play_timer_running:
		set_play_time(play_time + delta)


func _unhandled_input(_event):
	if Input.is_action_just_pressed("reset_level"):
		player_spawn_position = null
		load_level(current_level_index)
		spawn_player()
		start_timer()
		await get_tree().create_timer(1.0).timeout

	if Input.is_action_just_pressed("reset_checkpoint"):
		load_level(current_level_index)
		spawn_player()

	if Input.is_action_just_pressed("load_next_level"):
		var desired_level_index = current_level_index + 1
		if desired_level_index >= %Levels.get_number_of_levels():
			print("Already at last level.")
			desired_level_index = current_level_index
			return
		player_spawn_position = null
		load_level(desired_level_index)
		spawn_player()
		start_timer()

	if Input.is_action_just_pressed("load_previous_level"):
		var desired_level_index = current_level_index - 1
		if desired_level_index < 0:
			print("Already at first level.")
			desired_level_index = current_level_index
			return
		player_spawn_position = null
		load_level(desired_level_index)
		spawn_player()
		start_timer()


func load_level(desired_level_index):
	var loaded_successfully = %Levels.load_level(desired_level_index)
	if not loaded_successfully:
		printerr("Error: Level could not be loaded!")
	current_level_index = desired_level_index


func set_play_time(new_time):
	play_time = new_time
	%PlayTimeLabel.text = "%5.2f" % play_time


func start_timer():
	set_play_time(0.0)
	is_play_timer_running = true


func stop_timer():
	is_play_timer_running = false


func get_player_spawn_position():
	if player_spawn_position == null:
		player_spawn_position = %Levels.get_player_spawn_position_of_level()

	return player_spawn_position


func spawn_player():
	var player = null
	if get_node_or_null("Player") != null:
		player = $Player
		player.clear_abilities()
	else:
		var player_scene = preload("res://player/player.tscn")
		player = player_scene.instantiate()
		player.player_despawned.connect(on_player_despawned)
		player.player_reached_goal.connect(on_player_reached_goal)
		player.player_reached_checkpoint.connect(on_player_reached_checkpoint)

		var camera_node = get_node_or_null("Camera2D")

		var remote_transform = RemoteTransform2D.new()
		remote_transform.remote_path = camera_node.get_path()
		player.add_child(remote_transform)

		add_child.call_deferred(player)

	player.position = get_player_spawn_position()


func on_player_despawned():
	if get_node_or_null("Player") != null:
		await $Player.tree_exited

	load_level(current_level_index)
	spawn_player()


func on_player_reached_goal():
	stop_timer()


func on_player_reached_checkpoint(position):
	player_spawn_position = position
