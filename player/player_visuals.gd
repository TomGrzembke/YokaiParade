extends Node2D

#Note: Temporary implementation, just for visualisation

@export var trail_points_max = 4
@onready var attack_line: Line2D = $"../AttackLine"
@onready var attack_target: Node2D = $"../AttackTarget"
@onready var ability_visual: MeshInstance2D = %AbilityVisual
@onready var ability_target: Node2D = $"../AbilityTarget"
@export var hit_speed = .2

var hit_progress = .0
var is_attacking
var is_using_ability
var ability_progress = .0
var initial_pos
var initial_ability_pos

func _ready():
	initial_pos = position
	position = attack_target.position
	initial_ability_pos = ability_visual.position

func _process(delta):
	update_trail()
	flip()
	attack(delta)
	ability(delta)


func update_trail():
	attack_line.add_point(global_position - attack_line.global_position)

	if attack_line.get_point_count() > trail_points_max:
		attack_line.remove_point(0)


func flip():
	attack_line.scale.x = $"../..".look_direction


func attack(delta):
	if check_is_in_reset_range(attack_target, self): return

	hit_progress += delta / hit_speed
	position = position.slerp(attack_target.position, hit_progress)


func attack_command():
	position = initial_pos
	hit_progress = .0


func ability(delta):
	var is_in_reset_range = check_is_in_reset_range(ability_target, ability_visual)
	if Input.is_action_just_pressed("use_ability") && !is_in_reset_range:
		ability_visual.position = initial_ability_pos
		ability_progress = .0

	else:
		ability_progress += delta
		ability_visual.position = ability_visual.position.lerp(ability_target.position, ability_progress)


func check_is_in_reset_range(a, b):
	return a.position.length() - b.position.length() > 1.0
