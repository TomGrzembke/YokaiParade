extends GameState


func enter(p_previous_state):
	super.enter(p_previous_state)
	current_scene.set_previous_state(previous_state)
	current_scene.scene_finished.connect(change_state)
