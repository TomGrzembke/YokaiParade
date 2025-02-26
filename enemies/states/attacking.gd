extends EnemyStateCatchable


@export var lunging_state: EnemyState

var is_animation_running = false


func enter(p_previous_state):
	super.enter(p_previous_state)

	is_animation_running = true
	await state_animations_scene.enter_state_attacking()
	is_animation_running = false


func exit():
	super.exit()


func attack():
	parent.attack(parent.get_target_in_perception_area())


func physics_process(_delta):
	var next_state = check_caught()

	if next_state != null \
	or is_animation_running:
		return next_state

	if parent.get_target_in_perception_area() != null:
		next_state = lunging_state
	else:
		next_state = parent.get_initial_state()
	return next_state
