extends CharacterBody2D


signal enemy_caught(enemy)


const STATES = preload("res://enemies/states/enemy_states.gd")

@export_category("States")
@export var initial_state: STATES.EnemyState = STATES.EnemyState.IDLING
@export var recovery_time = 3.0

@export_category("Power")
@export var element_type: EnemyElementType

@export_category("Movement")
@export_enum("Right:1", "Left:-1") var initial_direction = 1
@export var speed = 150.0

@export_category("State Machine")
@export var idling_state: State
@export var moving_state: State
@export var recovering_state: State

var is_getting_caught = false
var direction


func _ready():
	direction = initial_direction
	if element_type != null:
		%MeshInstance2D.modulate = element_type.get_color()

	var init_state
	match initial_state:
		STATES.EnemyState.MOVING:
			init_state = moving_state
		STATES.EnemyState.RECOVERING:
			init_state = recovering_state
		_:
			init_state = idling_state
	%StateMachine.init(self, init_state)


func _unhandled_input(event):
	%StateMachine.unhandled_input(event)


func _physics_process(delta):
	%StateMachine.physics_process(delta)


func _process(delta):
	%StateMachine.process(delta)


func set_deal_damage_active(active):
	%DealDamageArea.set_deferred("monitoring", active)


func set_is_getting_caught(status):
	is_getting_caught = status


func get_is_getting_caught():
	return is_getting_caught


func get_recovery_time():
	return recovery_time


func handle_turn():
	if direction != null:
		if is_on_wall() \
		or is_on_cliff():
			flip_horizontally()


func flip_horizontally():
	direction *= -1.0
	scale.x *= -1.0


func is_on_cliff():
	return not %RayCast2D.is_colliding()


func set_alpha(alpha):
	var color = %MeshInstance2D.modulate
	color.a = alpha
	%MeshInstance2D.modulate = color


func got_caught(_source):
	enemy_caught.emit(self)
	is_getting_caught = true

	if element_type == null:
		return null
	return element_type.spawning_ability
