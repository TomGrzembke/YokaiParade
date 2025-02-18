class_name GameState
extends State


@export var game_state_packed_scene: PackedScene

var current_scene


func enter(p_previous_state: GameState):
	super.enter(p_previous_state)

	current_scene = game_state_packed_scene.instantiate()
	parent.load_game_state_scene(current_scene)


func exit():
	parent.unload_game_state_scene(current_scene)


func change_state(next_game_state):
	parent.change_to_game_state(next_game_state)
