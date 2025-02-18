extends GameState


@export var in_game_state: GameState
@export var options_game_state: GameState
@export var credits_game_state: GameState


func enter(p_previous_state):
	super.enter(p_previous_state)
	current_scene.set_in_game_state(in_game_state)
	current_scene.set_options_game_state(options_game_state)
	current_scene.set_credits_game_state(credits_game_state)
	current_scene.scene_finished.connect(change_state)
