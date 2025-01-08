extends CharacterBody2D


signal player_despawned


const ENEMY_SCRIPT = preload("res://enemies/enemy.gd")
const COLOR_PLAIN = Color("#949494")
const COLOR_AIR = Color("#dbdbdb")
const COLOR_FIRE = Color("#b05a5a")
const COLOR_WATER = Color("#5a8cb0")

@export var speed = 300.0
@export var jump_velocity = 600.0
@export var air_power_jump_velocity = 800.0


var body_in_catch_radius = null
var current_power = null:
	set = _set_current_power


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func _on_catch_radius_body_entered(body: Node2D) -> void:
	body_in_catch_radius = body


func _on_catch_radius_body_exited(body: Node2D) -> void:
	if body == body_in_catch_radius:
		body_in_catch_radius = null


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("catch_power") \
	and body_in_catch_radius != null \
	and body_in_catch_radius.has_method("caught"):
		current_power = body_in_catch_radius.caught()
		
	if Input.is_action_just_pressed("use_power") \
	and current_power != null:
		_use_power()


func _set_current_power(power):
	current_power = power
	var color = COLOR_PLAIN
	
	match power:
		ENEMY_SCRIPT.EnemyType.AIR:
			color = COLOR_AIR
		ENEMY_SCRIPT.EnemyType.FIRE:
			color = COLOR_FIRE
		ENEMY_SCRIPT.EnemyType.WATER:
			color = COLOR_WATER
		
	$MeshInstance2D.self_modulate = color


func _use_power():
	match current_power:
		ENEMY_SCRIPT.EnemyType.AIR:
			_use_air_power()
			
	current_power = null


func _use_air_power():
	velocity.y = -air_power_jump_velocity


func despawn():
	print("Eeeeeh")
	player_despawned.emit()
	queue_free()
