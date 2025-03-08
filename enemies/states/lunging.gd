extends EnemyStateCatchable


@export_category("Enemy States")
@export var attacking_enemy_state: EnemyState

@export_category("Components")
@export var target_direction_component: Node2D
@export var ranged_attack_component: Node2D


var is_animation_running = false


func enter(p_previous_state):
	super.enter(p_previous_state)

	is_animation_running = true
	await state_animations_scene.enter_state_lunging()
	is_animation_running = false


func physics_process(_delta):
	var next_state = check_caught()

	if next_state != null \
	or is_animation_running:
		return next_state

	var ranged_attack_target = ranged_attack_component.get_target_in_visible_range()
	if ranged_attack_target != null:
		next_state = attacking_enemy_state
		update_direction(ranged_attack_target)
	else:
		next_state = parent.get_initial_state()
	return next_state


func update_direction(look_at_target):
	if look_at_target != null:
		var new_direction = parent.global_position.direction_to(look_at_target.global_position).normalized()
		parent.set_look_direction(new_direction)
