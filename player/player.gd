extends CharacterBody2D

signal player_despawned
signal player_reached_goal

const COLOR_PLAIN = Color("#949494")
const COLOR_AIR = Color("#dbdbdb")
const COLOR_FIRE = Color("#b05a5a")
const COLOR_WATER = Color("#5a8cb0")

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
var body_in_catch_radius
var dash_direction
var move_direction

var velocity_outer_sources := Vector2(0,0)
var player_input_vel := Vector2(0,0)

@onready var ability_manager: Node2D = $AbilityManager

var velocity_mod_instigator = []
var player_control := true


func _physics_process(delta):
	calc_move_dir()
	handle_run()
	reset_y_vel_on_ground()
	handle_jump(delta)
	calc_dash_direction()
	handle_gravity(delta)
	
	velocity = player_input_vel
	#velocity = velocity_outer_sources
	
	move_and_slide()


func calc_move_dir():
	move_direction = sign(Input.get_axis("left", "right"))


func handle_run():
	if move_direction:
		player_input_vel.x = move_toward(player_input_vel.x, move_direction * speed, acceleration)
	else:
		player_input_vel.x = move_toward(player_input_vel.x, 0, deceleration)


func reset_y_vel_on_ground():
	if !is_on_floor(): return
	
	player_input_vel.y = 0


func handle_jump_buffer_time(delta):
	var jump_input = Input.is_action_just_pressed("jump")
	
	if jump_input || jump_buffer_timer > 0:
		jump_buffer_timer += delta
		
	if jump_input && jump_buffer_timer > 0:
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
	
	var should_jump = Input.is_action_just_pressed("jump") || can_use_jump_buffer()
	var can_jump = should_jump && is_on_floor() || can_use_coyote_time(should_jump)
	
	if can_jump:
		player_input_vel.y = -jump_velocity
	
	handle_jump_buffer_time(delta)


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


func calc_dash_direction():
	if move_direction != 0.0:
			dash_direction = move_direction


func handle_gravity(delta):
	clamp_fall_speed()
	player_input_vel.y += get_gravity().y * delta


func clamp_fall_speed():
	if fall_speed_clamp == 0: return;
	player_input_vel.y = clampf(player_input_vel.y, -1e20, fall_speed_clamp) 


func add_velocity_modifier(velocity_mod):
	#if velocity_mod.get_property_list().find("amount"):
		#print("exists")
	velocity_mod_instigator.append(velocity_mod)
	calc_vel_mod(velocity_mod, false)
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
	calc_vel_mod(velocity_mod, true)


func calc_vel_mod(velocity_mod, clear_mod):
	var highest_prioty = 5
	for i in range(velocity_mod_instigator.size() -1, -1, -1):
		highest_prioty = reapply_velocity_mods(velocity_mod, highest_prioty)
		
		if clear_mod && velocity_mod == velocity_mod_instigator[i]:
			velocity_mod_instigator.remove_at(i)



func delete_timer(given_timer):
	given_timer.queue_free()


func reapply_velocity_mods(velocity_mod, current_priority):
	if velocity_mod.priority > current_priority: return current_priority
	
	velocity_outer_sources = velocity_mod.amount
	player_control = !velocity_mod.disable_player_movement
	return velocity_mod.priority


func set_current_ability(ability_resource):
	ability_manager.set_current_ability(ability_resource)
	
	if ability_resource != null:
		$MeshInstance2D.self_modulate = ability_resource.color
	else:
		$MeshInstance2D.self_modulate = COLOR_PLAIN


func _on_catch_radius_body_entered(body):
	body_in_catch_radius = body


func _on_catch_radius_body_exited(body):
	if body == body_in_catch_radius:
		body_in_catch_radius = null


func _unhandled_input(_event):
	if Input.is_action_just_pressed("catch_power") \
	and body_in_catch_radius != null \
	and body_in_catch_radius.has_method("caught"):
		set_current_ability(body_in_catch_radius.caught())

	if Input.is_action_just_pressed("use_ability") \
	and ability_manager != null:
		ability_manager.use_ability(self)


func on_despawn():
	player_despawned.emit()
	queue_free()


func on_goal_reached():
	player_reached_goal.emit()
