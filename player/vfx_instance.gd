extends Node2D
@onready var anim_sprite
var rigid_body
var freeze_physics

func play(animation_name, emit_in_global = false, _freeze_physics = false, _z_index = null):
	rigid_body = $RigidBody2D
	anim_sprite = $RigidBody2D/AnimatedSprite2D

	if !has_anim(animation_name):
		queue_free()
		return

	anim_sprite.play(animation_name, 1.0, false)
	if emit_in_global: call_deferred("to_root")

	call_deferred("reset_rb")
	freeze_physics = _freeze_physics
	rigid_body.freeze = freeze_physics

	if _z_index != null:
		anim_sprite.z_index = _z_index


func to_root():
	reparent(get_tree().root)


func _physics_process(_delta):
	if scale.y == 1 && rotation == 0 && (rigid_body == null || rigid_body.rotation == 0): return

	reset_rb()


func has_anim(animation_name):
	return anim_sprite.sprite_frames.has_animation(animation_name)


func on_animation_finished():
	queue_free()
	pass


func reset_rb():
	scale.y = 1
	rotation = 0
	rigid_body.rotation = 0
