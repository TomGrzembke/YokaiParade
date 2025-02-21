extends Node2D


signal ability_changed(color)


const COLOR_PLAIN = Color("#949494")

var current_ability
var damage_subject

@onready var player: CharacterBody2D = $".."
@onready var visual: MeshInstance2D = %AbilityVisual
@export var hit_cooldown_time : float = .6
@export var hit_grace_time : float = .2
@export var hit_queue_time : float = .3
var hit_cooldown_timer
var hit_grace_timer
var hit_queue_timer

@onready var visualizer: Node2D =  $"../Visuals/AbilityVisualizer"
@onready var hit_enemy_ray: RayCast2D = $"../HitEnemyRay"
signal player_hits
signal used_ability


func _ready():
	hit_cooldown_timer = create_timer(0.1)


func _unhandled_input(_event):
	if Input.is_action_just_pressed("catch_ability"):
		catch_ability()

	if Input.is_action_just_pressed("use_ability"):
		use_ability()


func use_ability():
	if current_ability == null: return

	if current_ability.has_method("use"):
		current_ability.use(player)
		player.add_current_speed_tokens(1)
		used_ability.emit()

	reset_color()
	current_ability = null


func catch_ability():
	if hit_cooldown():
		hit_queue_timer = create_timer(hit_queue_time)
		return

	catch_grace_time()
	player_hits.emit()
	visualizer.attack_command()
	absorb_ability()


func absorb_ability():
	if damage_subject == null: return
	if hit_enemy_ray.has_target() && hit_enemy_ray.get_target() is TileMapLayer: return

	var subject_parent = damage_subject.get_damage_subject()
	if subject_parent == null: return
	if not subject_parent.has_method("got_caught"): return

	var ability = subject_parent.got_caught(self)
	set_current_ability(ability)


func hit_cooldown():
	if is_hit_on_cooldown(): return true

	hit_cooldown_timer = create_timer(hit_cooldown_time)
	hit_cooldown_timer.timeout.connect(hit_queue)
	return false


func is_hit_on_cooldown():
	return hit_cooldown_timer.time_left > 0


func hit_queue():
	if hit_queue_timer == null: return
	if hit_queue_timer.time_left > 0:
		catch_ability()


func catch_grace_time():
	if damage_subject != null: return

	if hit_timer_active():
		hit_grace_timer.set_time_left(hit_grace_time)
		return

	hit_grace_timer = create_timer(hit_grace_time)


func hit_timer_active():
	return hit_grace_timer != null && hit_grace_timer.time_left > 0


func set_current_ability(ability_scene):
	if ability_scene == null: return

	if current_ability != null:
		current_ability.exit()

	var ability = ability_scene.instantiate()
	add_child.call_deferred(ability)
	current_ability = ability

	if ability.has_method("get_color"):
		var ability_color: Color = ability.get_color()
		visual.self_modulate = ability_color
		ability_changed.emit(ability_color)


func clear_abilities():
	for child in get_children():
		child.queue_free()
	reset_color()


func create_timer(time):
	return get_tree().create_timer(time)


func reset_color():
	visual.self_modulate = COLOR_PLAIN
	ability_changed.emit(COLOR_PLAIN)


func get_current_ability():
	return current_ability

func on_deal_damage_area_entered(other):
	damage_subject = other

	if hit_timer_active():
		absorb_ability()


func on_deal_damage_area_exited(other):
	if other == damage_subject:
		damage_subject = null
