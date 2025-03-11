extends PathFollow2D


const STATES = preload("res://enemies/enemy_initial_states.gd")

@export_category("States")
@export var initial_state: STATES.EnemyInitialState = STATES.EnemyInitialState.IDLING
@export var recovery_time = 3.0

@export_category("Power")
@export var element_type: EnemyElementType

@export_category("Movement")
@export_enum("Right:1", "Left:-1") var initial_facing_direction = -1
@export var max_speed = 150.0
@export var easing_curve: Curve

@export_category("State Machine")
@export var idling_state: State
@export var moving_state: State

var path_2d


func _ready():
	path_2d = get_parent()

	check_validity()

	%PreviewSprite.visible = false

	var init_state = get_initial_state()
	%StateMachine.init(self, init_state)


func _physics_process(delta):
	%StateMachine.physics_process(delta)


func _process(delta):
	%StateMachine.process(delta)


func _unhandled_input(event):
	%StateMachine.unhandled_input(event)


func _input(event):
	%StateMachine.input(event)


func check_validity():
	var is_valid = true

	if element_type == null:
		printerr("No element_type resource set for enemy %s!" % self.get_path())
		is_valid = false

	if element_type != null \
	and element_type.animations_airborne == null:
		printerr("No animations for enemy %s provided in element type %s" % [self.get_path(), element_type])
		is_valid = false

	if path_2d == null:
		printerr("Enemy %s has no parent!" % self.get_path())
		is_valid = false

	if path_2d != null \
	   and path_2d.curve.get_baked_points().size() == 0:
		printerr("Curve in Path2D of enemy %s has no points!" % self.get_path())
		is_valid = false

	assert(is_valid, "Error: Enemy not set up properly, check errors in console!")


func get_element_animations_scene_instance():
	return element_type.animations_airborne.instantiate()


func get_initial_position():
	return %PreviewSprite.position


func get_initial_state():
	match initial_state:
		STATES.EnemyInitialState.MOVING:
			return moving_state
		_:
			return idling_state


func get_initial_facing_direction():
	match initial_facing_direction:
		1: return Vector2.RIGHT
		-1: return Vector2.LEFT


func get_max_speed():
	return max_speed


func get_is_path_closed():
	if path_2d.curve.get_point_position(0) == path_2d.curve.get_point_position(path_2d.curve.point_count - 1):
		return true

	return false


func get_path_length():
	return path_2d.curve.get_baked_length()
