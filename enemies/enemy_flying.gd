extends PathFollow2D

signal enemy_caught

enum EnemyState {
	IDLING = 100,
	MOVING = 200,
	RECOVERING = 300,
}

@export var starting_state: EnemyState = EnemyState.MOVING
@export var recovery_time = 3.0
@export var easing_curve: Curve
@export var max_speed = 200.0
@export var element_type: EnemyElementType

@onready var deal_damage_area: Area2D = $DealDamageArea

var state
var speed = 0.0
var path_length = 0.0
var is_path_closed = false
var progression_direction = 1.0
var progress_ratio_raw = 0.0


func _ready():
	state = starting_state
	check_is_path_closed()
	speed = max_speed
	path_length = get_parent().curve.get_baked_length()
	if element_type != null:
		%MeshInstance2D.modulate = element_type.get_color()


func check_is_path_closed():
	var path = get_parent()
	if path == null \
	and path:
		return

	if path.curve.get_point_position(0) == path.curve.get_point_position(path.curve.point_count - 1):
		is_path_closed = true
	else:
		is_path_closed = false


func _physics_process(delta):
	match state:
		EnemyState.IDLING:
			process_idling(delta)
		EnemyState.MOVING:
			process_moving(delta)


func process_idling(_delta):
	pass


func process_moving(delta):
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


func enter_state(new_state):
	match new_state:
		EnemyState.IDLING:
			enter_state_idling()
		EnemyState.MOVING:
			enter_state_moving()
		EnemyState.RECOVERING:
			enter_state_recovering()

	refresh_hitbox()


func enter_state_idling():
	set_alpha(1.0)
	state = EnemyState.IDLING


func enter_state_moving():
	set_alpha(1.0)
	state = EnemyState.MOVING


func enter_state_recovering():
	var last_state = state
	set_alpha(0.1)
	state = EnemyState.RECOVERING
	var recovery_timer = get_tree().create_timer(recovery_time)
	recovery_timer.timeout.connect(enter_state.bind(last_state))


func set_alpha(alpha):
	var color = %MeshInstance2D.modulate
	color.a = alpha
	%MeshInstance2D.modulate = color


func got_caught():
	if state == EnemyState.RECOVERING:
		return null

	enemy_caught.emit()
	enter_state(EnemyState.RECOVERING)
	return element_type.spawning_ability


func refresh_hitbox():
	deal_damage_area.monitoring = state != EnemyState.RECOVERING
