extends Node2D
var anim_sprite
var rigid_body
var freeze_physics

func play(animation_name, emit_in_global = false, _freeze_physics = false):
	rigid_body = $RigidBody2D
	anim_sprite = $RigidBody2D/AnimatedSprite2D
	anim_sprite.play(animation_name, 1.0, false)
	if emit_in_global: call_deferred("to_root")

	call_deferred("reset_rb")
	freeze_physics = _freeze_physics
	rigid_body.freeze = freeze_physics


func to_root():
	reparent(get_tree().root)


func _physics_process(_delta):
	if scale.y == 1 && rotation == 0 && (rigid_body == null || rigid_body.rotation == 0): return

	reset_rb()


func on_animation_finished():
	queue_free()
	pass


func reset_rb():
	scale.y = 1
	rotation = 0
	rigid_body.rotation = 0
