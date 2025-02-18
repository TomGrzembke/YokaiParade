extends CharacterBody2D

signal player_despawned
signal player_reached_checkpoint(position)
signal player_reached_goal

const INFINITY = 1e20

@export_category("Movement")
@export var speed = 300.0
@export var acceleration = 80.0
@export var deceleration = 50.0
@export var outer_deceleration = 50.0
@export var jump_velocity = 600.0
@export var fall_speed_clamp = 600.0
@export_category("Movement extras")
@export_range(0.0, 1.0, .01) var jump_coyote_time = .15
@export_range(0.0, 1.0, .01) var jump_buffer_time = .15
@export_range(0.0, 1.0, .01) var variable_jump_height_min_percentage = .7
@export_range(0.0, .99, .01) var jump_height_continuous_cut_percentage = 1.0
@export_category("Apex Settings")
@export var jump_edge_correction_time : float = 0.1
@export var apex_time : float = .1
@export var apex_strength : float = 1000.0
@export_range(0, 1.0, .01) var apex_negativ_gravity : float = .5
@export var apex_smooth_curve : Curve

@export_category("Enemey Push")
@export var push_back = 500.0
@export_range(.0, 1.5, .1) var push_height_percentage = .75

@onready var abilities: Node2D = $Abilities
@onready var upper_edge_detection_ray: RayCast2D = $UpperEdgeDetectionRay
@onready var downer_edge_detection_ray: RayCast2D = $DownerEdgeDetectionRay


var coyote_timer = 0.15
var jump_buffer_timer = 0.0

var look_direction = 1.0
var move_dir

var local_velocity := Vector2.ZERO
var outer_velocity_sources := Vector2.ZERO
var cached_local_velocity := Vector2.ZERO

var velocity_mod_instigator = []
var player_control := true

var buffer_cancel_jump := false
var is_cancelling_jump := false
var jump_edge_correction_timer
var is_using_edge_correction
var apex_timer
var can_use_apex

var debug_mode = false
var debug_speed_modifier = 3

func _physics_process(delta):
	if debug_mode:
		debug_logic()
		return

	if player_control:
		run()
		update_gravity(delta)
		jump(delta)

	ability_smoothing()
	calc_vel_mods()
	apply_velocity()
	clamp_fall_speed()
	move_and_slide()


func apply_velocity():
	velocity = local_velocity + outer_velocity_sources


func run():
	calc_move_dir()
	calc_look_direction()

	if move_dir:
		local_velocity.x = move_toward(local_velocity.x, move_dir * speed, acceleration)
	else:
		local_velocity.x = move_toward(local_velocity.x, 0, deceleration)
	flip()


func update_gravity(delta):
	local_velocity.y += get_gravity().y * delta

	fall_on_ceiling(delta)

	reset_vertical_velocity()


func ability_smoothing():
	if check_movement_mods_empty():
		outer_velocity_sources.x = move_toward(outer_velocity_sources.x, 0, outer_deceleration)

		if is_on_floor():
			outer_velocity_sources.y = 0


func jump(delta):
	coyote_time(delta)
	jump_logic()
	apex_modifier(delta)
	variable_jump_height()
	update_jump_buffer(delta)
	cached_local_velocity = local_velocity

	if is_on_floor():
		is_using_edge_correction = false

	if upper_edge_detection_ray.has_target():
		return

	if downer_edge_detection_ray.has_target() && !is_using_edge_correction:
		jump_edge_correction_timer = create_timer(jump_edge_correction_time)
		is_using_edge_correction = true
		local_velocity.x *= -1



func calc_move_dir():
	move_dir = sign(Input.get_axis("left", "right"))


func calc_look_direction():
	if move_dir == 0.0: return

	look_direction = move_dir


func flip():
	if look_direction == 0: return

	set_rotation_degrees(0.0 if look_direction == 1.0 else -180.0)
	scale.y = look_direction


func fall_on_ceiling(delta):
	if velocity.y: return
	if local_velocity.y or receives_outer_vertical_velocity():
		local_velocity.y = get_gravity().y * delta
		outer_velocity_sources.y = 0


func coyote_time(delta):
	if is_on_floor() || receives_outer_vertical_velocity() || is_cancelling_jump:
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


func variable_jump_height():
	var is_falling = local_velocity.y < 0
	var cancel_pressed = Input.is_action_just_released("jump")
	var will_cancel = cancel_pressed && is_falling
	var use_cancel_buffer = buffer_cancel_jump && is_on_floor()

	if will_cancel || use_cancel_buffer:
		is_cancelling_jump = true
		cut_initial_jump()
		buffer_cancel_jump = false

	if is_on_floor():
		is_cancelling_jump = false

	if can_use_jump_buffer() && cancel_pressed:
		buffer_cancel_jump = true

	cut_continuos_jump(is_falling)


func cut_initial_jump():
	if variable_jump_height_min_percentage == 0: return

	local_velocity.y *= variable_jump_height_min_percentage


func cut_continuos_jump(is_falling):
	if !is_falling: return
	if jump_height_continuous_cut_percentage != 0: return

	local_velocity.y *= jump_height_continuous_cut_percentage


func update_jump_buffer(delta):
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


func apex_modifier(delta):
	if apex_time == 0: return
	if apex_strength == 0 && apex_negativ_gravity == 0: return
	if is_on_floor():
		can_use_apex = true
		return

	if cached_local_velocity.y < 0.0 && local_velocity.y > 0.0 && can_use_apex:
		apex_timer = create_timer(apex_time)
		can_use_apex = false

	if apex_timer == null: return
	if apex_timer.time_left <= 0: return

	apex_horizontal(delta)
	apex_vertical()


func apex_horizontal(delta):
	local_velocity.y -= get_gravity().y * delta * apex_negativ_gravity


func apex_vertical():
	if local_velocity.x == 0: return
	if apex_smooth_curve == null:
		local_velocity.x += look_direction * apex_strength
		return

	local_velocity.x += look_direction * \
	lerpf(apex_strength * .5, apex_strength, apex_smooth_curve.sample(apex_timer.time_left / apex_time))


func add_velocity_modifier(velocity_mod):
	velocity_mod_instigator.append(velocity_mod)
	calc_vel_mods()
	create_vel_duration_timer(velocity_mod)


func create_vel_duration_timer(velocity_mod):
	var duration_timer = create_timer(velocity_mod.duration)
	duration_timer.timeout.connect(on_vel_mod_ended.bind(velocity_mod))
	velocity_mod.set_timer(duration_timer)


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


func clear_abilities():
	abilities.clear_abilities()


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
	outer_velocity_sources = velocity_mod.amount * velocity_mod.sample_curve()


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
		push_vel.y *= push_height_percentage
		add_velocity_modifier(VelocityModifier.new(push_vel, .2, 3, true))

		if Input.get_connected_joypads().size() > 0:
			Input.start_joy_vibration(0, 0.5, 0.0, 0.5)


func create_timer(time):
	return get_tree().create_timer(time)


func toggle_debug():
	debug_mode = !debug_mode
	return debug_mode


func set_debug_speed_modifier(modifier):
	debug_speed_modifier = modifier


func debug_logic():
	debug_movement()


func debug_movement():
	velocity = Vector2(Input.get_vector("left", "right", "up", "down")).normalized()
	velocity *= speed * debug_speed_modifier
	run()
	move_and_slide()
