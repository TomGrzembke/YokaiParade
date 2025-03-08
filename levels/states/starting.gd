extends LevelState


@export var next_level_state: LevelState


func enter(p_previous_state):
	super.enter(p_previous_state)

	parent.set_player_controls_active(false)

	parent.play_game_music()


func exit():
	super.exit()

	parent.set_player_controls_active(true)


func unhandled_input(event):
	if event.is_action_pressed("skip"):
		change_to_next_level_state()


func change_to_next_level_state():
	change_state(next_level_state)
