extends CharacterBody2D


signal enemy_caught(enemy)


const STATES = preload("res://enemies/enemy_initial_states.gd")

@export_category("States")
@export var initial_state: STATES.EnemyInitialState = STATES.EnemyInitialState.IDLING
@export var recovery_time = 3.0

@export_category("Power")
@export var element_type: EnemyElementType

@export_category("Movement")
@export_enum("Right:1", "Left:-1") var initial_look_direction = -1
@export var speed = 150.0

@export_category("State Machine")
@export var idling_state: State
@export var moving_state: State

var is_recovering = false
var state_animations_scene
var look_direction
var target_in_perception_area


func _ready():
	check_validity()

	state_animations_scene = element_type.animations_grounded.instantiate()
	add_child(state_animations_scene)

	state_animations_scene.position = %Sprite2D.position
	%Sprite2D.visible = false

	reset_look_direction()

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


func get_initial_state():
	match initial_state:
		STATES.EnemyInitialState.MOVING:
			return moving_state
		_:
			return idling_state


func get_state_animations_scene():
	return state_animations_scene


func get_target_in_perception_area():
	return target_in_perception_area


func set_look_direction(value):
	look_direction = value
	if look_direction != null:
		state_animations_scene.update_direction(look_direction)


func get_look_direction():
	return look_direction


func reset_look_direction():
	var direction
	match initial_look_direction:
		1: direction = Vector2.RIGHT
		-1: direction = Vector2.LEFT
	set_look_direction(direction)


func get_speed():
	return speed


func set_deal_bump_damage_active(active):
	%DealBumpDamageArea.set_deferred("monitoring", active)


func on_perception_area_entered(target):
	var subject = %DealAttackDamageArea.get_damageable_subject(target)

	if subject == null: return

	target_in_perception_area = subject
	var target_direction = global_position.direction_to(target_in_perception_area.global_position)
	set_look_direction(target_direction)


func on_perception_area_exited(_target):
	target_in_perception_area = null


func on_bump_damage_area_entered(target):
	attack(%DealBumpDamageArea.get_damageable_subject(target))


func attack(target):
	if target == null: return

	target.on_took_damage(self)


# TODO: Try getting rid of this and setting monitoring and state change by returning from state

func get_recovery_time():
	return recovery_time

func set_is_recovering(status):
	is_recovering = status


func get_is_recovering():
	return is_recovering

# End


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
