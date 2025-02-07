extends Node
class_name State


var parent = null


func init(parent_node):
	parent = parent_node


func enter(_previous_state):
	return null


func exit():
	return null


func process(_delta):
	return null


func physics_process(_delta):
	return null


func unhandled_input(_event):
	return null
