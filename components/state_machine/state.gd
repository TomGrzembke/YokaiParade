extends Node
class_name State


var parent
var previous_state


func init(parent_node):
	parent = parent_node


func enter(p_previous_state):
	previous_state = p_previous_state
	return null


func exit():
	return null


func process(_delta):
	return null


func physics_process(_delta):
	return null


func unhandled_input(_event):
	return null
