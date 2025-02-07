extends "res://enemies/states/catchable_state.gd"


func physics_process(_delta):
	return check_caught()
