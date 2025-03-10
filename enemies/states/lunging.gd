extends EnemyStateCatchable


@export_category("Enemy States")
@export var attacking_melee_enemy_state: EnemyState
@export var attacking_ranged_enemy_state: EnemyState

@export_category("Components")
@export var target_direction_component: Node2D
@export var attack_melee_component: Node2D
@export var attack_ranged_component: Node2D


var is_entering_state = false


func enter(p_previous_state):
	is_entering_state = true
	super.enter(p_previous_state)

	await visualisation_component.enter_state_lunging()

	is_entering_state = false


func physics_process(_delta):
	var next_state = check_caught()

	if next_state != null \
	or is_entering_state:
		return next_state

	var attack_ranged_target = attack_ranged_component.get_target_in_visible_range()
	if attack_melee_component.get_target_in_range() != null:
		next_state = attacking_melee_enemy_state
	elif attack_ranged_target != null:
		next_state = attacking_ranged_enemy_state
		update_direction(attack_ranged_target)
	else:
		next_state = parent.get_initial_state()
	return next_state


func update_direction(look_at_target):
	if look_at_target != null:
		var new_direction = parent.global_position.direction_to(look_at_target.global_position).normalized()
		visualisation_component.set_facing_direction(new_direction)
