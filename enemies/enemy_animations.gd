extends Node2D


var animation_state_machine
var state_node


func _ready():
	animation_state_machine = %AnimationTree.get("parameters/playback")


func set_state_node(node):
	state_node = node


func update_direction(direction):
	%AnimationTree.set("parameters/Idling/blend_position", direction.x)
	%AnimationTree.set("parameters/Moving/blend_position", direction)
	%AnimationTree.set("parameters/Lunging/blend_position", direction.x)
	%AnimationTree.set("parameters/Attacking/blend_position", direction.x)
	%AnimationTree.set("parameters/Recovering/blend_position", direction.x)


func enter_state_idling():
	animation_state_machine.travel("Idling")


func enter_state_moving():
	animation_state_machine.travel("Moving")


func enter_state_lunging():
	animation_state_machine.travel("Lunging")
	await %AnimationTree.animation_finished


func enter_state_attacking():
	animation_state_machine.travel("Attacking")
	await %AnimationTree.animation_finished


func attack():
	if state_node == null: return
	if not state_node.has_method("attack"): return

	state_node.attack()


func enter_state_recovering():
	animation_state_machine.travel("Recovering")
