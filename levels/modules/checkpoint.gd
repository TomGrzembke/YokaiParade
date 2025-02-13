extends Area2D


const TEXTURE_ACTIVE = preload("res://levels/modules/checkpoint_active.png")


func on_checkpoint_area_entered(other):
	if other != null \
	and other.has_method("on_reached_checkpoint"):
		other.on_reached_checkpoint(global_position)
		%Sprite2D.texture = TEXTURE_ACTIVE
