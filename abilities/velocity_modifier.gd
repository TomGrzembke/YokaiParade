extends Node
class_name VelocityModifier

var amount
var duration
var priority #1 = abilities, 2 = enemy attacks
var disable_player_movement = false
var ability

func _init(_amount, _duration, _priority, _disable_player_movement):
	amount = _amount
	duration = _duration
	priority = _priority
	disable_player_movement = _disable_player_movement


func set_ability(_ability):
	ability = _ability
