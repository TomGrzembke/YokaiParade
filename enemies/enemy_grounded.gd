extends CharacterBody2D


const STATES = preload("res://enemies/enemy_initial_states.gd")

@export_category("States")
@export var initial_state: STATES.EnemyInitialState = STATES.EnemyInitialState.IDLING
@export var recovery_time = 3.0

@export_category("Power")
@export var element_type: EnemyElementType

@export_category("Movement")
@export_enum("Right:1", "Left:-1") var initial_facing_direction = -1
@export var speed = 150.0

@export_category("State Machine")
@export var idling_state: State
@export var moving_state: State


func _ready():
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

	assert(is_valid, "Error: Enemy not set up properly, check errors above!")


func get_element_animations_scene_instance():
	return element_type.animations_grounded.instantiate()


func get_element_type():
	return element_type


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


func get_speed():
	return speed
