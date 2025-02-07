extends State


@export var recovering_state: State


func check_caught():
	if parent != null \
	and parent.get_is_getting_caught():
		return recovering_state
