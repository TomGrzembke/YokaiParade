class_name LevelState
extends State


@export var level_state_packed_scene: PackedScene

var state_scene


func enter(p_previous_state):
	super.enter(p_previous_state)

	if level_state_packed_scene == null:
		return

	state_scene = level_state_packed_scene.instantiate()
	state_scene.set_state_node(self)
	parent.load_level_state_scene(state_scene)


func exit():
	super.exit()

	if state_scene == null:
		return

	parent.unload_level_state_scene(state_scene)


func change_state(next_level_state):
	parent.change_to_level_state(next_level_state)
