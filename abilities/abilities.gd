extends Node2D

var current_ability
const ENEMY_SCRIPT = preload("res://enemies/enemy.gd")


func _process(delta: float) -> void:
	pass


func use_ability():
	if current_ability == null: return
	
	if current_ability.has_method("use"):
		current_ability.use()
		
	current_ability = null


func set_current_ability(ability_resource):
	current_ability = ability_resource
	
	var ability = ability_resource.ability_scene.instantiate()
	add_child(ability)
