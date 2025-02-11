extends Node
class_name VelocityModifier

var amount
var duration
var priority #1 = abilities, 2 = enemy attacks
var disable_player_movement = false
var ability
var invert_with_look_dir
var curve
var timer

func _init(_amount, _duration, _priority, _disable_player_movement, _invert_with_look_dir = false):
	amount = _amount
	duration = _duration
	priority = _priority
	disable_player_movement = _disable_player_movement
	invert_with_look_dir = _invert_with_look_dir


func set_ability(_ability):
	ability = _ability


func set_curve(_curve):
	curve = _curve


func set_timer(_timer):
	timer = _timer


func sample_curve():
	if curve == null: return 1
	if timer == null: return 1
	return curve.sample((duration - timer.time_left) / duration)
