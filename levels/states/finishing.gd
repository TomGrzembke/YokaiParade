extends LevelState


@export var next_level_state: LevelState


func enter(p_previous_state):
	super.enter(p_previous_state)

	state_scene.set_state_node(self)

	parent.dim_music_volume(0.2)
	parent.set_player_controls_active(false)


func change_to_next_level_state():
	change_state(next_level_state)


func reset_music_volume(duration):
	await parent.reset_music_volume(duration)
