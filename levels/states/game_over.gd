extends LevelState


@export var return_to_main_menu_level_state: LevelState


func enter(p_previous_state):
	super.enter(p_previous_state)

	state_scene.set_state_node(self)

	state_scene.set_return_to_main_menu_level_state(return_to_main_menu_level_state)
