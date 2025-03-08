extends LevelState


@export var next_level_state: LevelState

var stored_volume_linear


func enter(p_previous_state):
	super.enter(p_previous_state)

	stored_volume_linear = get_music_volume_linear()

	state_scene.music_volume_fraction_changed.connect(set_music_volume_fraction)

	parent.set_player_controls_active(false)


func change_to_next_level_state():
	change_state(next_level_state)


func set_music_volume_fraction(fraction):
	parent.set_music_volume(linear_to_db(stored_volume_linear * fraction))


func get_music_volume_linear():
	return db_to_linear(parent.get_music_volume())
