extends CharacterBody2D

signal player_despawned
signal player_reached_goal

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

var current_delta
var coyote_timer = 0.15
var jump_buffer_timer = 0.0

var look_direction = 0.0
var move_direction

var local_velocity := Vector2(0,0)
var outer_velocity_sources := Vector2(0,0)

var velocity_mod_instigator = []
var player_control := true


func _physics_process(delta):
	current_delta = delta

	if player_control:
		handle_run()
		handle_gravity()
		handle_jump()

	handle_ability_dissolve()

	velocity = local_velocity + outer_velocity_sources

	clamp_fall_speed()
	move_and_slide()


func handle_run():
	calc_move_dir()
	calc_look_direction()

	if move_direction:
		local_velocity.x = move_toward(local_velocity.x, move_direction * speed, acceleration)
	else:
		local_velocity.x = move_toward(local_velocity.x, 0, deceleration)


func calc_move_dir():
	move_direction = sign(Input.get_axis("left", "right"))


func calc_look_direction():
	if move_direction != 0.0:
			look_direction = move_direction


func handle_jump():
	handle_coyote_time()
	jump_logic()
	handle_jump_buffer_time()


func handle_coyote_time():
	if is_on_floor():
		coyote_timer = 0.0
	else:
		coyote_timer += current_delta


func jump_logic():
	var should_jump = Input.is_action_just_pressed("jump") || can_use_jump_buffer()
	var can_jump = should_jump && is_on_floor() || can_use_coyote_time(should_jump)
	if !can_jump: return

	local_velocity.y = -jump_velocity


func handle_jump_buffer_time():
	var jump_input = Input.is_action_just_pressed("jump")

	if jump_input:
		jump_buffer_timer = current_delta

	elif jump_buffer_timer > 0:
		jump_buffer_timer += current_delta

	if is_on_floor():
		jump_buffer_timer = 0.0


func can_use_coyote_time(should_jump):
	if jump_coyote_time == 0: return false
	if coyote_timer == 0: return false
	if !should_jump: return false
	if local_velocity.y < 0: return false

	return coyote_timer < jump_coyote_time


func can_use_jump_buffer():
	if jump_buffer_time == 0: return false
	if jump_buffer_timer == 0: return false

	return jump_buffer_timer < jump_buffer_time


func handle_gravity():
	local_velocity.y += get_gravity().y * current_delta
	reset_y_vel_on_ground()


func reset_y_vel_on_ground():
	if !is_on_floor(): return

	local_velocity.y = 0


func clamp_fall_speed():
	if fall_speed_clamp == 0: return;
	velocity.y = clampf(velocity.y, -INFINITY, fall_speed_clamp)


func handle_ability_dissolve():
	if check_movement_mods_empty():
		outer_velocity_sources.x = move_toward(outer_velocity_sources.x, 0, deceleration)

		if is_on_floor():
			outer_velocity_sources.y = 0

func add_velocity_modifier(velocity_mod):
	velocity_mod_instigator.append(velocity_mod)
	calc_vel_mods()
	create_vel_duration_timer(velocity_mod)


func create_vel_duration_timer(velocity_mod):
	var duration_timer = Timer.new()
	add_child(duration_timer)

	duration_timer.wait_time = velocity_mod.duration
	duration_timer.one_shot = true
	duration_timer.timeout.connect(on_vel_mod_ended.bind(velocity_mod))
	duration_timer.timeout.connect(duration_timer.queue_free)
	duration_timer.start()


func on_vel_mod_ended(velocity_mod):
	delete_vel_mod(velocity_mod)
	calc_vel_mods()


func calc_vel_mods():
	var highest_prioty = 5
	for i in range(velocity_mod_instigator.size() -1, -1, -1):
		highest_prioty = refresh_velocity_mods(velocity_mod_instigator[i], highest_prioty)


func delete_vel_mod(velocity_mod):
	var velocity_id = velocity_mod_instigator.find(velocity_mod)
	if velocity_id != -1:
		velocity_mod_instigator.remove_at(velocity_id)

	if check_movement_mods_empty():
		reset_velocity_mod_effects(velocity_mod)


func reset_velocity_mod_effects(velocity_mod):
	player_control = true
	if velocity_mod.ability != null:
		velocity_mod.ability.queue_free()


func check_movement_mods_empty():
	return velocity_mod_instigator.size() == 0


func refresh_velocity_mods(velocity_mod, current_priority):
	if velocity_mod.priority > current_priority: return current_priority

	apply_vel_mod(velocity_mod)

	refresh_needed_local_vel(velocity_mod)

	flip_outer_velocity_logic()

	return velocity_mod.priority


func apply_vel_mod(velocity_mod):
	player_control = !velocity_mod.disable_player_movement
	outer_velocity_sources = velocity_mod.amount


func refresh_needed_local_vel(velocity_mod):
	if velocity_mod.amount.y != 0:
		local_velocity.y = 0

	if velocity_mod.amount.x != 0:
		local_velocity.x = 0
		local_velocity.y = 0


func flip_outer_velocity_logic():
	if look_direction < 0:
		outer_velocity_sources.x = -outer_velocity_sources.x


func on_despawn():
	player_despawned.emit()
	queue_free()


func on_goal_reached():
	player_reached_goal.emit()


func on_took_damage(source):
	if source != null \
	and source.position != null:

		#add_velocity_modifier(VelocityModifier.new(Vector2(-300, -20), .2, 3, false, null))
		print("Player hit!") # TODO: Stumble back and make invincible for a while, see GDD
		#note: temporary implementation, just moves you in the flipped look_dir rn
		#note: stun locks player rn even when theyre dead (ask chris for fix with enemies)
		#note: also possible to just slow the player
