extends LevelState


@export var next_level_state: LevelState


func change_to_next_level_state():
	change_state(next_level_state)


func reset_level():
	await parent.reset_level()
