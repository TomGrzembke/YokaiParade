extends CharacterBody2D

signal enemy_caught

enum EnemyState {
	IDLING = 100,
	MOVING = 200,
	RECOVERING = 300,
}


@export var starting_state: EnemyState = EnemyState.MOVING
@export var recovery_time = 3.0
@export var speed = 100.0
@export var initial_direction = 1.0
@export var element_type: EnemyElementType

@onready var deal_damage_area: Area2D = $DealDamageArea

var state
var direction


func _ready():
	state = starting_state
	direction = initial_direction
	if element_type != null:
		%MeshInstance2D.modulate = element_type.get_color()


func _physics_process(delta):
	handle_gravity(delta)
	handle_turn()
	handle_movement(delta)

	move_and_slide()


func handle_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta


func handle_turn():
	if direction != null:
		if is_on_wall() \
		or is_on_cliff():
			flip_horizontally()


func handle_movement(_delta):
	match state:
		EnemyState.MOVING:
			velocity.x = direction * speed
		_: velocity.x = 0.0


func flip_horizontally():
	direction *= -1.0
	scale.x *= -1.0


func is_on_cliff():
	return not %RayCast2D.is_colliding()


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


func got_caught(_source):
	if state == EnemyState.RECOVERING:
		return null

	enemy_caught.emit()
	enter_state(EnemyState.RECOVERING)

	if element_type == null:
		return null
	return element_type.spawning_ability


func refresh_hitbox():
	deal_damage_area.set_deferred("monitoring", state != EnemyState.RECOVERING)
