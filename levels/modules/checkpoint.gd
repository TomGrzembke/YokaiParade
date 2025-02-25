extends Area2D


@export var texture_inactive: Texture2D
@export var texture_active: Texture2D


func _ready():
	%Sprite2D.texture = texture_inactive


func on_checkpoint_area_entered(other):
	if other != null \
	and other.has_method("on_reached_checkpoint"):
		other.on_reached_checkpoint(global_position)
		%Sprite2D.texture = texture_active
