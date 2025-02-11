extends State


@export var recovering_state: State


func check_caught():
	if parent != null \
	and parent.get_is_recovering():
		return recovering_state
