class_name GameState
extends State


@export var game_state_packed_scene: PackedScene

var state_scene


func enter(p_previous_state):
	super.enter(p_previous_state)

	if game_state_packed_scene == null:
		return

	state_scene = game_state_packed_scene.instantiate()
	state_scene.set_state_node(self)
	parent.load_game_state_scene(state_scene)


func exit():
	super.exit()

	if state_scene == null:
		return

	parent.unload_game_state_scene(state_scene)


func change_state(next_game_state):
	parent.change_to_game_state(next_game_state)
