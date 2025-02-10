extends "res://enemies/states/catchable_state.gd"


func enter(_last_state):
	parent.enter_animation_state_idling()


func physics_process(delta):
	parent.handle_gravity(delta)
	parent.move_and_slide()

	return check_caught()
