extends EnemyStateCatchable


@export_category("Components")
@export var attack_melee_component: Node2D

var is_animation_running = false


func enter(p_previous_state):
	super.enter(p_previous_state)

	is_animation_running = true
	await visualisation_component.enter_state_attacking()
	is_animation_running = false


func attack():
	var target = attack_melee_component.get_target_in_range()
	if target == null \
	or not target.has_method("on_took_damage"): return

	target.on_took_damage(parent)


func physics_process(_delta):
	var next_state = check_caught()

	if next_state != null \
	or is_animation_running:
		return next_state

	next_state = parent.get_initial_state()
	return next_state
