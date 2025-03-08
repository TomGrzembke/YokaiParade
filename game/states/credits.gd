extends GameState


# Game States

func enter(p_previous_state):
	super.enter(p_previous_state)

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func exit():
	super.exit()

	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func change_to_previous_state():
	change_state(previous_state)
