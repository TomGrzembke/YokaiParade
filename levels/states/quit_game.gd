extends LevelState


func enter(_p_previous_state):
	super.enter(_p_previous_state)

	parent.change_to_quit_game_state()
