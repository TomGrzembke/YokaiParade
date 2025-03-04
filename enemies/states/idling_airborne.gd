extends EnemyStateCatchable


@export var lunging_enemy_state: EnemyState


func enter(p_previous_state):
	super.enter(p_previous_state)

	state_animations_scene.enter_state_idling()


func physics_process(_delta):
	var next_state = check_caught()
	if next_state != null:
		return next_state

	if parent.get_target_in_perception_area() != null:
		next_state = lunging_enemy_state

	return next_state
