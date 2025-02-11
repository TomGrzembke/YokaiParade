extends "res://enemies/states/catchable_state.gd"


func enter(_last_state):
	parent.enter_animation_state_idling()


func physics_process(_delta):
	return check_caught()
