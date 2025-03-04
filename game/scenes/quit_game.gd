extends Node


var state_node


func _ready():
	%AnimationPlayer.stop()
	%AnimationPlayer.play("blackout")

	await %AnimationPlayer.animation_finished

	get_tree().quit()


func fade_out_audio(duration):
	await state_node.fade_out_audio(duration)


func set_state_node(node):
	state_node = node
