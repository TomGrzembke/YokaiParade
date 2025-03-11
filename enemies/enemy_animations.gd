extends Node2D


enum AnimationState {
	IDLING = 100,
	MOVING = 200,
	LUNGING = 300,
	ATTACKING = 400,
	RECOVERING = 500,
}


signal idling_animation_finished
signal moving_animation_finished
signal lunging_animation_finished
signal attacking_animation_finished
signal recovering_animation_finished


var direction
var state_node

var animation_state = AnimationState.IDLING

var blend_spaces


func _ready():
	blend_spaces = {
		AnimationState.IDLING: %IdlingBlendSpace,
		AnimationState.MOVING: %MovingBlendSpace,
		AnimationState.LUNGING: %LungingBlendSpace,
		AnimationState.ATTACKING: %AttackingBlendSpace,
		AnimationState.RECOVERING: %RecoveringBlendSpace,
	}

	for key in blend_spaces.keys():
		blend_spaces[key].active = false
		blend_spaces[key].animation_finished.connect(specify_animation_finished_signal)


func _physics_process(_delta):
	update_blend_position(blend_spaces[animation_state])


func set_state_node(node):
	state_node = node


func update_blend_position(blend_space):
	if blend_space.tree_root.min_space is Vector2:
		blend_space.set("parameters/blend_position", direction)
	else:
		blend_space.set("parameters/blend_position", sign(direction.x))


func update_direction(p_direction):
	direction = p_direction


func set_animation_state(state):
	animation_state = state
	activate_blend_space(state)


func activate_blend_space(p_key):
	for key in blend_spaces.keys():
		if key == p_key:
			blend_spaces[key].active = true
		else:
			blend_spaces[key].active = false


func attack():
	if state_node == null: return
	if not state_node.has_method("attack"): return

	state_node.attack()


func specify_animation_finished_signal(animation_name: String):
	if animation_name.begins_with("idling"):
		idling_animation_finished.emit()
	elif animation_name.begins_with("moving"):
		moving_animation_finished.emit()
	elif animation_name.begins_with("lunging"):
		lunging_animation_finished.emit()
	elif animation_name.begins_with("attacking"):
		attacking_animation_finished.emit()
	elif animation_name.begins_with("recovering"):
		recovering_animation_finished.emit()
