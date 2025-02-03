extends CharacterBody2D

signal player_despawned
signal player_reached_checkpoint(position)
signal player_reached_goal

const INFINITY = 1e20

@export_category("Movement")
@export var speed = 300.0
@export var acceleration = 80.0
@export var deceleration = 50.0
@export var jump_velocity = 600.0
@export var fall_speed_clamp = 600.0
@export_category("Movement extras")
@export_range(.0, 1.0, .01) var jump_coyote_time = .15
@export_range(.0, 1.0, .01) var jump_buffer_time = .15
@export_range(.0, 1, .01) var initial_jump_heigth_smooth = .7
@export_range(.0, .9, .01) var jump_heigth_smooth = .6
@export_category("Enemey Push")
@export var push_back = 500.0
@export_range(.0, 1.5, .1) var push_heigth_percentage = .75

@onready var ability_manager: Node2D = $AbilityManager


var coyote_timer = 0.15
var jump_buffer_timer = 0.0

var look_direction = 1.0
var move_direction

var local_velocity := Vector2(0,0)
var outer_velocity_sources := Vector2(0,0)

var velocity_mod_instigator = []
var player_control := true
var is_cancelling_jump := false


func _physics_process(delta):
	if player_control:
		run()
		update_gravity(delta)
		jump(delta)

	ability_smoothing()

	velocity = local_velocity + outer_velocity_sources

	clamp_fall_speed()
	move_and_slide()


func run():
	calc_move_dir()
	calc_look_direction()

	if move_direction:
		local_velocity.x = move_toward(local_velocity.x, move_direction * speed, acceleration)
	else:
		local_velocity.x = move_toward(local_velocity.x, 0, deceleration)

	flip()


func update_gravity(delta):
	local_velocity.y += get_gravity().y * delta

	fall_on_ceiling(delta)

	reset_vertical_velocity()


func ability_smoothing():
	if check_movement_mods_empty():
		outer_velocity_sources.x = move_toward(outer_velocity_sources.x, 0, deceleration)

		if is_on_floor():
			outer_velocity_sources.y = 0


func jump(delta):
	handle_coyote_time(delta)
	jump_logic()
	variable_jump_heigth()
	handle_jump_buffer_time(delta)


func calc_move_dir():
	move_direction = sign(Input.get_axis("left", "right"))


func calc_look_direction():
	if move_direction == 0.0: return

	look_direction = move_direction


func flip():
	if look_direction == 0: return

	set_rotation_degrees(0.0 if look_direction == 1.0 else -180.0)
	scale.y = look_direction


func fall_on_ceiling(delta):
	if velocity.y: return

	if local_velocity.y or receives_outer_vertical_velocity():
		local_velocity.y = get_gravity().y * delta
		outer_velocity_sources.y = 0


func handle_coyote_time(delta):
	if is_on_floor() || receives_outer_vertical_velocity():
		coyote_timer = 0.0
	else:
		coyote_timer += delta


func receives_outer_vertical_velocity():
	return outer_velocity_sources.y


func jump_logic():
	var should_jump = Input.is_action_just_pressed("jump") || can_use_jump_buffer()
	var can_jump = should_jump && is_on_floor() || can_use_coyote_time(should_jump)
	if !can_jump: return

	local_velocity.y = -jump_velocity


func variable_jump_heigth():
	if Input.is_action_just_released("jump") && player_control && local_velocity.y < 0:
		if initial_jump_heigth_smooth != 0:
			local_velocity.y *= initial_jump_heigth_smooth
		is_cancelling_jump = true

	if is_on_floor():
		is_cancelling_jump = false

	if is_cancelling_jump && local_velocity.y < 0:
		if jump_heigth_smooth != 0:
			local_velocity.y *= jump_heigth_smooth


func handle_jump_buffer_time(delta):
	var jump_input = Input.is_action_just_pressed("jump")

	if jump_input:
		jump_buffer_timer = delta

	elif jump_buffer_timer > 0:
		jump_buffer_timer += delta

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


func reset_vertical_velocity():
	if !is_on_floor(): return

	local_velocity.y = 0


func clamp_fall_speed():
	if fall_speed_clamp == 0: return;
	velocity.y = clampf(velocity.y, -INFINITY, fall_speed_clamp)


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


func clear_abilities():
	ability_manager.clear_abilities()


func check_movement_mods_empty():
	return velocity_mod_instigator.size() == 0


func refresh_velocity_mods(velocity_mod, current_priority):
	if velocity_mod.priority > current_priority: return current_priority

	apply_vel_mod(velocity_mod)

	refresh_needed_local_vel(velocity_mod)

	flip_outer_velocity_logic(velocity_mod)

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


func flip_outer_velocity_logic(velocity_mod):
	if !velocity_mod.invert_with_look_dir: return

	if look_direction < 0:
		outer_velocity_sources.x = -outer_velocity_sources.x


func on_despawn():
	if Input.get_connected_joypads().size() > 0:
		Input.start_joy_vibration(0, 1.0, 0.0, 2.0)
	player_despawned.emit()
	queue_free()


func on_goal_reached():
	player_reached_goal.emit()


func on_reached_checkpoint(checkpoint_position):
	if checkpoint_position != null:
		player_reached_checkpoint.emit(checkpoint_position)


func on_took_damage(source):
	if source != null:
		var push_vel = -(source.global_position - position).normalized() * push_back
		push_vel.y *= push_heigth_percentage
		add_velocity_modifier(VelocityModifier.new(push_vel, .2, 3, true))
		# TODO: Stumble back and make invincible for a while, see GDD
		#note: temporary implementation
		if Input.get_connected_joypads().size() > 0:
			Input.start_joy_vibration(0, 0.5, 0.0, 0.5)
