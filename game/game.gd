extends Node


@export var initial_state: State


var current_game_state_scene


func _ready() -> void:
	%StateMachine.init(self, initial_state)


func load_game_state_scene(game_state_scene):
	current_game_state_scene = game_state_scene
	add_child(current_game_state_scene)


func unload_game_state_scene(game_state_scene):
	var scene_to_be_removed
	for child in get_children():
		if child == game_state_scene:
			scene_to_be_removed = game_state_scene
	if scene_to_be_removed != null:
		remove_child(scene_to_be_removed)


func change_to_game_state(game_state: GameState):
	%StateMachine.change_state(game_state)
