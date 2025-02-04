extends Area2D


func _ready():
	%Visual.modulate.a = 0.2


func on_checkpoint_area_entered(other):
	if other != null \
	and other.has_method("on_reached_checkpoint"):
		other.on_reached_checkpoint(global_position)
		%Visual.modulate.a = 1.0
