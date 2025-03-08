extends GameState


@export var in_game_state: GameState
@export var options_game_state: GameState
@export var credits_game_state: GameState
@export var quit_game_state: GameState


# Game States

func enter(p_previous_state):
	super.enter(p_previous_state)

	state_scene.set_in_game_state(in_game_state)
	state_scene.set_options_game_state(options_game_state)
	state_scene.set_credits_game_state(credits_game_state)
	state_scene.set_quit_game_state(quit_game_state)

	parent.play_title_music()

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func exit():
	super.exit()

	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
