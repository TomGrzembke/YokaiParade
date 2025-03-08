extends GameState


@export var next_game_state: GameState


func play_title_music():
	parent.play_title_music()


# Game States

func enter(p_previous_state):
	super.enter(p_previous_state)


func unhandled_input(event):
	if event.is_action_pressed("skip"):
		change_to_next_game_state()


func change_to_next_game_state():
	change_state(next_game_state)
