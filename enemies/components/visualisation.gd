extends Node2D


@export var entity: Node2D

var state_animations_scene
var facing_direction


func _ready():
	state_animations_scene = entity.get_element_animations_scene_instance()
	add_child(state_animations_scene)

	state_animations_scene.position = entity.get_initial_position()
	set_facing_direction(entity.get_initial_facing_direction())


func set_state_node(node):
	state_animations_scene.set_state_node(node)


func set_facing_direction(value):
	facing_direction = value
	if facing_direction != null:
		state_animations_scene.update_direction(facing_direction)


func get_facing_direction():
	return facing_direction


func enter_state_idling():
	state_animations_scene.set_animation_state(state_animations_scene.AnimationState.IDLING)


func enter_state_moving():
	state_animations_scene.set_animation_state(state_animations_scene.AnimationState.MOVING)


func enter_state_lunging():
	state_animations_scene.set_animation_state(state_animations_scene.AnimationState.LUNGING)
	await state_animations_scene.lunging_animation_finished


func enter_state_attacking():
	state_animations_scene.set_animation_state(state_animations_scene.AnimationState.ATTACKING)
	await state_animations_scene.attacking_animation_finished


func enter_state_recovering():
	state_animations_scene.set_animation_state(state_animations_scene.AnimationState.RECOVERING)
	await state_animations_scene.recovering_animation_finished
