extends PathFollow2D


signal enemy_caught(enemy)


const STATES = preload("res://enemies/enemy_initial_states.gd")

@export_category("States")
@export var initial_state: STATES.EnemyInitialState = STATES.EnemyInitialState.IDLING
@export var recovery_time = 3.0

@export_category("Power")
@export var element_type: EnemyElementType

@export_category("Movement")
@export_enum("Right:1", "Left:-1") var initial_look_direction = -1
@export var max_speed = 150.0
@export var easing_curve: Curve

@export_category("State Machine")
@export var idling_state: State
@export var moving_state: State
@export var recovering_state: State

var is_getting_caught = false
var enemy_animations
var look_direction


func _ready():
	if element_type.animations_airborne != null:
		enemy_animations = element_type.animations_airborne.instantiate()
		add_child(enemy_animations)

		enemy_animations.position = %Sprite2D.position
		%Sprite2D.visible = false

		var direction
		match initial_look_direction:
			1: direction = Vector2.RIGHT
			2: direction = Vector2.LEFT
		set_direction(direction)

	var init_state
	match initial_state:
		STATES.EnemyInitialState.MOVING:
			init_state = moving_state
		_:
			init_state = idling_state

	%StateMachine.init(self, init_state)


func _unhandled_input(event):
	%StateMachine.unhandled_input(event)


func _physics_process(delta):
	%StateMachine.physics_process(delta)


func _process(delta):
	%StateMachine.process(delta)


func set_direction(value):
	look_direction = value
	if look_direction != null:
		enemy_animations.update_direction(look_direction.x)


func get_direction():
	return look_direction


func get_max_speed():
	return max_speed


func get_recovery_time():
	return recovery_time


func set_deal_damage_active(active):
	%DealDamageArea.set_deferred("monitoring", active)


func set_is_getting_caught(status):
	is_getting_caught = status


func get_is_getting_caught():
	return is_getting_caught


func enter_animation_state_moving():
	enemy_animations.enter_state_moving()


func enter_animation_state_idling():
	enemy_animations.enter_state_idling()


func enter_animation_state_recovering():
	enemy_animations.enter_state_recovering()


func get_is_path_closed():
	var path = get_parent()
	if path == null \
	and path:
		return

	if path.curve.get_point_position(0) == path.curve.get_point_position(path.curve.point_count - 1):
		return true

	return false


func get_path_length():
	return get_parent().curve.get_baked_length()


func got_caught(_source):
	enemy_caught.emit(self)
	is_getting_caught = true

	if element_type == null:
		return null
	return element_type.spawning_ability
