extends EnemyStateCatchable


@export_category("Enemy States")
@export var attacking_melee_enemy_state: EnemyState
@export var lunging_enemy_state: EnemyState

@export_category("Components")
@export var target_direction_component: Node2D
@export var attack_melee_component: Node2D
@export var attack_ranged_component: Node2D


func enter(p_previous_state):
	super.enter(p_previous_state)

	state_animations_scene.enter_state_idling()


func physics_process(delta):
	parent.handle_gravity(delta)
	parent.move_and_slide()

	var target_direction = target_direction_component.get_target_direction()
	var new_direction

	if target_direction != null:
		new_direction = Vector2(target_direction.x, 0.0).normalized()
	else:
		new_direction = parent.get_initial_look_direction()

	if new_direction != null:
		parent.set_look_direction(new_direction)

	var next_state = check_caught()
	if next_state != null:
		return next_state

	if attack_melee_component.get_target_in_range() != null:
		next_state = attacking_melee_enemy_state
	elif attack_ranged_component.get_target_in_visible_range() != null:
		next_state = lunging_enemy_state

	return next_state
