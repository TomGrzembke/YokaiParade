extends GameState


@export var next_game_state: GameState


func enter(p_previous_state):
	super.enter(p_previous_state)
	current_scene.set_title_game_state(next_game_state)
	current_scene.scene_finished.connect(change_state)
