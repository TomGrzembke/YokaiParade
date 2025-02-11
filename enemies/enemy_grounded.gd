extends CharacterBody2D


signal enemy_caught(enemy)


const STATES = preload("res://enemies/enemy_initial_states.gd")

@export_category("States")
@export var initial_state: STATES.EnemyInitialState = STATES.EnemyInitialState.IDLING
@export var recovery_time = 3.0

@export_category("Power")
@export var element_type: EnemyElementType

@export_category("Movement")
@export_enum("Right:1", "Left:-1") var initial_direction = -1
@export var speed = 150.0

@export_category("State Machine")
@export var idling_state: State
@export var moving_state: State
@export var recovering_state: State

var is_recovering = false
var enemy_animations
var direction


func _ready():
	if element_type.animations_grounded != null:
		enemy_animations = element_type.animations_grounded.instantiate()
		add_child(enemy_animations)

		enemy_animations.position = %Sprite2D.position
		%Sprite2D.visible = false

		set_direction(initial_direction)

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
	direction = value
	enemy_animations.update_direction(direction)


func get_direction():
	return direction


func get_speed():
	return speed


func get_recovery_time():
	return recovery_time


func set_deal_damage_active(active):
	%DealDamageArea.set_deferred("monitoring", active)


func set_is_recovering(status):
	is_recovering = status


func get_is_recovering():
	return is_recovering


func enter_animation_state_moving():
	enemy_animations.enter_state_moving()


func enter_animation_state_idling():
	enemy_animations.enter_state_idling()


func enter_animation_state_recovering():
	enemy_animations.enter_state_recovering()


func handle_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta


func is_on_cliff():
	return \
	( \
		not %RayCast2DRight.is_colliding() \
		or not %RayCast2DLeft.is_colliding() \
	) \
	and is_on_floor()


func got_caught(_source):
	if is_recovering:
		return null

	enemy_caught.emit(self)
	is_recovering = true

	if element_type == null:
		return null
	return element_type.spawning_ability
