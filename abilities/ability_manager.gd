extends Node2D


const COLOR_PLAIN = Color("#949494")


var current_ability
var damage_subject

@onready var player: CharacterBody2D = $".."
@onready var visual: MeshInstance2D = %AbilityVisual
@export var hit_cooldown : float = .6
@export var hit_grace_time : float = .2
var hit_grace_active
var hit_grace_timer


func _unhandled_input(_event):
	if Input.is_action_just_pressed("catch_power"):
		catch_power()

	if Input.is_action_just_pressed("use_ability"):
		use_ability()


func use_ability():
	if current_ability == null: return

	if current_ability.has_method("use"):
		current_ability.use(player)

	reset_color()
	current_ability = null

func catch_power():
	catch_grace_time()

	if damage_subject == null: return
	var target_parent = damage_subject.get_damage_subject()
	if target_parent == null: return
	if not target_parent.has_method("got_caught"): return

	var ability = target_parent.got_caught(self)
	set_current_ability(ability)


func catch_grace_time():
	if damage_subject != null: return
	hit_grace_active = true

	if hit_timer_active():
		hit_grace_timer.set_time_left(hit_grace_time)
		return

	hit_grace_timer = create_timer(hit_grace_time)
	hit_grace_timer.timeout.connect(func(): hit_grace_active = false)


func hit_timer_active():
	return hit_grace_timer != null && hit_grace_timer.time_left > 0


func set_current_ability(ability_scene):
	if ability_scene == null: return

	var ability = ability_scene.instantiate()
	add_child.call_deferred(ability)
	current_ability = ability

	if ability.has_method("get_color"):
		visual.self_modulate = ability.get_color()


func clear_abilities():
	for child in get_children():
		child.queue_free()
	reset_color()


func create_timer(time):
	return get_tree().create_timer(time)


func reset_color():
	visual.self_modulate = COLOR_PLAIN


func get_current_ability():
	return current_ability


func on_deal_damage_area_entered(other):
	damage_subject = other

	if hit_grace_active:
		catch_power()


func on_deal_damage_area_exited(other):
	if other == damage_subject:
		damage_subject = null
