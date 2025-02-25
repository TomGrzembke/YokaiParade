extends Node2D


var animation_state_machine


func _ready():
	animation_state_machine = %AnimationTree.get("parameters/playback")
	%AnimationTree.animation_finished.connect(temp)


func temp(name):
	print("animation %s finished" % name)

func update_direction(direction):
	%AnimationTree.set("parameters/Idling/blend_position", direction)
	%AnimationTree.set("parameters/Moving/blend_position", direction)
	%AnimationTree.set("parameters/Lunging/blend_position", direction)
	%AnimationTree.set("parameters/Attacking/blend_position", direction)
	%AnimationTree.set("parameters/Recovering/blend_position", direction)


func enter_state_idling():
	animation_state_machine.travel("Idling")


func enter_state_moving():
	animation_state_machine.travel("Moving")


func enter_state_lunging():
	animation_state_machine.travel("Lunging")
	print("not finished")
	await %AnimationTree.animation_finished
	print("finished")


func enter_state_attacking():
	animation_state_machine.travel("Attacking")
	await %AnimationTree.animation_finished


func enter_state_recovering():
	animation_state_machine.travel("Recovering")
