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
@export_category("Movement extras")
@export_range(0.0, 1.0, 0.01) var jump_coyote_time = 0.15
@export_range(0.0, 1.0, 0.01) var jump_buffer_time = 0.15
@export_category("Powers")
@export var air_power_jump_velocity = 800.0
@export var fire_power_dash_velocity = 300.0
@export var fire_power_dash_duration = 1.0

var coyote_timer = 0.15
var jump_buffer_timer = 0.0
var body_in_catch_radius
var body_in_damage_radius
var is_dashing := false
var dash_direction
var move_direction

var current_power:
	set = _set_current_power

func _physics_process(delta):
	if is_dashing:
		apply_dash_damage()
	else:
		move_direction = sign(Input.get_axis("left", "right"))
		
		handle_run()
		
		handle_jump(delta)
		
		calc_dash_direction()
		handle_gravity(delta)
	
	move_and_slide()


func handle_run():
	if move_direction:
		velocity.x = move_toward(velocity.x, move_direction * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)


func handle_jump_buffer_time(delta):
	if Input.is_action_just_pressed("jump") || jump_buffer_timer > 0:
		jump_buffer_timer += delta
		
	if Input.is_action_just_pressed("jump") && jump_buffer_timer > 0:
		jump_buffer_timer = delta
		
	if is_on_floor():
		jump_buffer_timer = 0.0


func handle_coyote_time(delta):
	if is_on_floor():
		coyote_timer = 0.0
	else:
		coyote_timer += delta


func handle_jump(delta):
	handle_coyote_time(delta)
	
	var should_jump = Input.is_action_just_pressed("jump") || evaluate_jump_buffer()
	var can_jump = should_jump && is_on_floor() || evaluate_coyote_time(should_jump)
	
	if can_jump:
		velocity.y = -jump_velocity
	
	handle_jump_buffer_time(delta)


func evaluate_coyote_time(should_jump):
	if jump_coyote_time == 0: return false
	if coyote_timer == 0: return false
	if !should_jump: return false
	if velocity.y < 0: return false
	return coyote_timer < jump_coyote_time 


func evaluate_jump_buffer():
	if jump_buffer_time == 0: return false
	if jump_buffer_timer == 0: return false
	return jump_buffer_timer < jump_buffer_time


func apply_dash_damage():
	if body_in_damage_radius == null: return
	if !body_in_damage_radius.has_method("take_damage"): return
	
	body_in_damage_radius.take_damage()


func calc_dash_direction():
	if move_direction != 0.0:
			dash_direction = move_direction


func handle_gravity(delta):
	velocity += get_gravity() * delta


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
