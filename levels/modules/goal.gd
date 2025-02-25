extends Area2D


@export var texture_inactive: Texture2D
@export var texture_active: Texture2D


func _ready():
	%Sprite2D.texture = texture_inactive


func on_body_entered(other):
	if other != null \
	and other.has_method("on_goal_reached"):
		other.on_goal_reached()
		%Sprite2D.texture = texture_active
