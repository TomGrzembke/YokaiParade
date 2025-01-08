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
@export var fire_power_dash_velocity = 300.0
@export var fire_power_dash_duration = 1.0


var _body_in_catch_radius = null
var _current_power = null:
	set = _set_current_power

var _is_dashing = false:
	set(new_value):
		_is_dashing = new_value
		if _is_dashing == true:
			%DealDamageArea.set_collision_layer_value(2, true)
		else:
			%DealDamageArea.set_collision_layer_value(2, false)
var _dash_direction = null


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if !_is_dashing:
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = -jump_velocity

		var direction = sign(Input.get_axis("left", "right"))
		if direction != 0.0:
			_dash_direction = direction
	
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func _on_catch_radius_body_entered(body: Node2D) -> void:
	_body_in_catch_radius = body


func _on_catch_radius_body_exited(body: Node2D) -> void:
	if body == _body_in_catch_radius:
		_body_in_catch_radius = null


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("catch_power") \
	and _body_in_catch_radius != null \
	and _body_in_catch_radius.has_method("caught"):
		_current_power = _body_in_catch_radius.caught()
		
	if Input.is_action_just_pressed("use_power") \
	and _current_power != null:
		_use_power()


func _set_current_power(power):
	_current_power = power
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
	match _current_power:
		ENEMY_SCRIPT.EnemyType.AIR:
			_use_air_power()
		ENEMY_SCRIPT.EnemyType.FIRE:
			_use_fire_power()
			
	_current_power = null


func _use_air_power():
	velocity.y = -air_power_jump_velocity


func _use_fire_power():
	_is_dashing = true
	velocity.y = 0.0
	velocity.x = fire_power_dash_velocity * _dash_direction
	%DashTimer.wait_time = fire_power_dash_duration
	%DashTimer.start()
	await %DashTimer.timeout
	_is_dashing = false


func despawn():
	player_despawned.emit()
	queue_free()
