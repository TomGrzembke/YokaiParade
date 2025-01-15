extends CharacterBody2D

signal player_despawned
signal player_reached_goal

const ENEMY_SCRIPT = preload("res://enemies/enemy.gd")
const COLOR_PLAIN = Color("#949494")
const COLOR_AIR = Color("#dbdbdb")
const COLOR_FIRE = Color("#b05a5a")
const COLOR_WATER = Color("#5a8cb0")

@export_category("Movement")
@export var speed = 300.0
@export var acceleration = 80.0
@export var deceleration = 50.0
@export var jump_velocity = 600.0
@export_range(0.0, 1.0, 0.01) var jump_coyote_time = 0.15
@export_category("Powers")
@export var air_power_jump_velocity = 800.0
@export var fire_power_dash_velocity = 300.0
@export var fire_power_dash_duration = 1.0

var coyote_timer = 0.15
var body_in_catch_radius = null
var body_in_damage_radius = null
var is_dashing = false
var dash_direction = null

var current_power:
	set = _set_current_power

func set_current_power(value):
	current_power = value

func get_current_power():
	return current_power

func _physics_process(delta):
	if !is_dashing:
		if is_on_floor():
			coyote_timer = 0.0
		else:
			coyote_timer += delta
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") \
		and coyote_timer < jump_coyote_time:
			velocity.y = -jump_velocity

		var direction = sign(Input.get_axis("left", "right"))
		if direction != 0.0:
			dash_direction = direction

		if direction:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration)
		else:
			velocity.x = move_toward(velocity.x, 0, deceleration)
	else:
		if body_in_damage_radius != null \
		and body_in_damage_radius.has_method("take_damage"):
			body_in_damage_radius.take_damage()

	move_and_slide()


func _on_catch_radius_body_entered(body):
	body_in_catch_radius = body


func _on_catch_radius_body_exited(body):
	if body == body_in_catch_radius:
		body_in_catch_radius = null


func _unhandled_input(_event):
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
		ENEMY_SCRIPT.EnemyType.FIRE:
			_use_fire_power()

	current_power = null


func _use_air_power():
	velocity.y = -air_power_jump_velocity


func _use_fire_power():
	is_dashing = true
	velocity.y = 0.0
	velocity.x = fire_power_dash_velocity * dash_direction
	%DashTimer.wait_time = fire_power_dash_duration
	%DashTimer.start()
	await %DashTimer.timeout
	is_dashing = false


func on_despawn():
	player_despawned.emit()
	queue_free()


func on_goal_reached():
	player_reached_goal.emit()


func _on_deal_damage_area_body_entered(body):
	body_in_damage_radius = body


func _on_deal_dash_damage_area_body_exited(_body):
	body_in_damage_radius = null
