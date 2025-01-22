extends PathFollow2D

signal enemy_caught

@export var easing_curve: Curve
@export var max_speed = 200.0
@export var element_type: EnemyElementType

var speed = 0.0
var is_path_closed = false
var progression_direction = 1.0
var progress_ratio_raw = 0.0

var path_length = 0.0


func _ready():
	check_is_path_closed()
	speed = max_speed
	path_length = get_parent().curve.get_baked_length()
	if element_type != null:
		%MeshInstance2D.modulate = element_type.get_color()


func _physics_process(delta):
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

		if easing_curve != null:
			progress_ratio = easing_curve.sample(progress_ratio_raw)
		else:
			progress_ratio = progress_ratio_raw

	else:
		progress_ratio = progress_ratio_raw


func check_is_path_closed():
	var path = get_parent()
	if path == null \
	and path:
		return

	if path.curve.get_point_position(0) == path.curve.get_point_position(path.curve.point_count - 1):
		is_path_closed = true
	else:
		is_path_closed = false


func got_caught():
	enemy_caught.emit()
	# TODO: Stun enemy, start timer for recovery
	return element_type.spawning_ability
