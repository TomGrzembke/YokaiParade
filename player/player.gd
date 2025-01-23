extends CharacterBody2D

signal player_despawned
signal player_reached_goal

const COLOR_PLAIN = Color("#949494")
const INFINITY = 1e20

@export_category("Movement")
@export var speed = 300.0
@export var acceleration = 80.0
@export var deceleration = 50.0
@export var jump_velocity = 600.0
@export var fall_speed_clamp = 600.0
@export_category("Movement extras")
@export_range(0.0, 1.0, 0.01) var jump_coyote_time = 0.15
@export_range(0.0, 1.0, 0.01) var jump_buffer_time = 0.15

var coyote_timer = 0.15
var jump_buffer_timer = 0.0
var look_direction
var move_direction

var velocity_outer_sources := Vector2(0,0)
var player_input_vel := Vector2(0,0)

@onready var ability_manager: Node2D = $AbilityManager

var velocity_mod_instigator = []
var player_control := true


func _physics_process(delta):
	if player_control:
		handle_run()
		handle_gravity(delta)
		handle_jump(delta)

	handle_ability_smoothing()
	velocity = player_input_vel + velocity_outer_sources
	clamp_fall_speed()
	move_and_slide()


func handle_run():
	calc_move_dir()
	calc_look_direction()

	if move_direction:
		player_input_vel.x = move_toward(player_input_vel.x, move_direction * speed, acceleration)
	else:
		player_input_vel.x = move_toward(player_input_vel.x, 0, deceleration)


func calc_move_dir():
	move_direction = sign(Input.get_axis("left", "right"))


func calc_look_direction():
	if move_direction != 0.0:
			look_direction = move_direction


func handle_jump(delta):
	handle_coyote_time(delta)
	jump_logic()
	handle_jump_buffer_time(delta)


func reset_y_vel_on_ground():
	if !is_on_floor(): return

	player_input_vel.y = 0


func handle_coyote_time(delta):
	if is_on_floor():
		coyote_timer = 0.0
	else:
		coyote_timer += delta


func jump_logic():
	var should_jump = Input.is_action_just_pressed("jump") || can_use_jump_buffer()
	var can_jump = should_jump && is_on_floor() || can_use_coyote_time(should_jump)
	if !can_jump: return

	player_input_vel.y = -jump_velocity


func handle_jump_buffer_time(delta):
	var jump_input = Input.is_action_just_pressed("jump")

	if jump_input && jump_buffer_timer > 0:
		jump_buffer_timer = delta

	elif jump_input || jump_buffer_timer > 0:
		jump_buffer_timer += delta


	if is_on_floor():
		jump_buffer_timer = 0.0


func can_use_coyote_time(should_jump):
	if jump_coyote_time == 0: return false
	if coyote_timer == 0: return false
	if !should_jump: return false
	if player_input_vel.y < 0: return false
	return coyote_timer < jump_coyote_time


func can_use_jump_buffer():
	if jump_buffer_time == 0: return false
	if jump_buffer_timer == 0: return false
	return jump_buffer_timer < jump_buffer_time


func handle_gravity(delta):
	player_input_vel.y += get_gravity().y * delta
	reset_y_vel_on_ground()


func clamp_fall_speed():
	if fall_speed_clamp == 0: return;
	velocity.y = clampf(velocity.y, -INFINITY, fall_speed_clamp)


func handle_ability_smoothing():
	if no_movement_mods_active():
		velocity_outer_sources.x = move_toward(velocity_outer_sources.x, 0, deceleration)

		if is_on_floor():
			velocity_outer_sources.y = 0

func add_velocity_modifier(velocity_mod):
	velocity_mod_instigator.append(velocity_mod)
	calc_vel_mods(velocity_mod, false)
	create_vel_duration_timer(velocity_mod)


func create_vel_duration_timer(velocity_mod):
	var duration_timer = Timer.new()
	duration_timer.wait_time = velocity_mod.duration
	duration_timer.one_shot = true
	add_child(duration_timer)
	duration_timer.timeout.connect(on_vel_mod_ended.bind(velocity_mod))
	duration_timer.timeout.connect(delete_timer.bind(duration_timer))
	duration_timer.start()


func on_vel_mod_ended(velocity_mod):
	calc_vel_mods(velocity_mod, true)


func calc_vel_mods(velocity_mod, clear_mod):
	var highest_prioty = 5
	for i in range(velocity_mod_instigator.size() -1, -1, -1):
		highest_prioty = reapply_velocity_mods(velocity_mod, highest_prioty)

		if clear_mod && velocity_mod == velocity_mod_instigator[i]:
			velocity_mod_instigator.remove_at(i)

	if no_movement_mods_active():
		reset_velocity_mod_effects(velocity_mod)


func reset_velocity_mod_effects(velocity_mod):
	player_control = true
	velocity_mod.ability.queue_free()


func no_movement_mods_active():
	return velocity_mod_instigator.size() == 0


func delete_timer(given_timer):
	given_timer.queue_free()


func reapply_velocity_mods(velocity_mod, current_priority):
	if velocity_mod.priority > current_priority: return current_priority

	velocity_outer_sources = velocity_mod.amount

	player_input_vel = Vector2(0,0)
	player_control = !velocity_mod.disable_player_movement

	if look_direction < 0:
		velocity_outer_sources.x = -velocity_outer_sources.x

	return velocity_mod.priority


func on_despawn():
	player_despawned.emit()
	queue_free()


func on_goal_reached():
	player_reached_goal.emit()


func on_took_damage(source):
	if source != null \
	and source.position != null:
		print("Player hit!") # TODO: Stumble back and make invincible for a while, see GDD
