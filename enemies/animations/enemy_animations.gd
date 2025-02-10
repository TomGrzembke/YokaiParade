extends Node2D


var state_machine


func _ready():
	state_machine = %AnimationTree.get("parameters/playback")


func update_direction(direction):
	%AnimationTree.set("parameters/Moving/blend_position", direction)
	%AnimationTree.set("parameters/Recovering/blend_position", direction)
	%AnimationTree.set("parameters/Idling/blend_position", direction)


func enter_state_moving():
	state_machine.travel("Moving")


func enter_state_recovering():
	state_machine.travel("Recovering")


func enter_state_idling():
	state_machine.travel("Idling")
