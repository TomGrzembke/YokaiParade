extends EnemyStateCatchable


@export var lunging_state: EnemyState

var last_position
var speed = 0.0
var path_length = 0.0
var is_path_closed = false
var progression_direction = 1.0
var progress_ratio_raw = 0.0


func init(p_parent):
	super.init(p_parent)

	speed = parent.get_max_speed()
	path_length = parent.get_path_length()
	is_path_closed = parent.get_is_path_closed()


func enter(p_previous_state):
	super.enter(p_previous_state)

	state_animations_scene.enter_state_moving()


func physics_process(delta):
	var step_ratio = (speed / path_length) * delta * progression_direction
	progress_ratio_raw += step_ratio
	if not is_path_closed:
		var overflow = wrap(abs(progress_ratio_raw), 0.0, 1.0)

		if progress_ratio_raw >= 1.0:
			progress_ratio_raw -= overflow
			progression_direction = -1.0
		elif progress_ratio_raw <= 0.0:
			progress_ratio_raw += overflow
			progression_direction = 1.0

		if parent.easing_curve != null:
			parent.progress_ratio = parent.easing_curve.sample(progress_ratio_raw)
		else:
			parent.progress_ratio = progress_ratio_raw

	else:
		parent.progress_ratio = progress_ratio_raw

	update_direction()

	return check_caught()


func update_direction():
	var position = parent.global_position
	if last_position == null:
		last_position = position
		return

	parent.set_look_direction((position - last_position).normalized())
	last_position = position
