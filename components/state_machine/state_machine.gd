extends Node


var current_state


func init(parent, initial_state):
	current_state = initial_state
	for child in get_children():
		child.init(parent)

	change_state(current_state)


func change_state(new_state):
	if new_state == null:
		printerr("Error: State to change to must not be null!")
		return

	var previous_state = current_state

	if current_state != null:
		current_state.exit()

	current_state = new_state
	current_state.enter(previous_state)


func process(delta):
	var new_state = current_state.process(delta)
	if new_state != null:
		change_state(new_state)


func physics_process(delta):
	var new_state = current_state.physics_process(delta)
	if new_state != null:
		change_state(new_state)


func unhandled_input(event):
	var new_state = current_state.unhandled_input(event)
	if new_state != null:
		change_state(new_state)
