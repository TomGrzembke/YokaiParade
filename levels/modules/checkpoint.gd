extends Area2D


@export var texture_inactive: Texture2D
@export var texture_active: Texture2D
@onready var spawnpoint = $Spawnpoint


func _ready():
	%Sprite2D.texture = texture_inactive


func on_checkpoint_area_entered(other):
	if !other.has_method("on_reached_checkpoint"): return

	other.on_reached_checkpoint(spawnpoint.global_position)
	%Sprite2D.texture = texture_active
