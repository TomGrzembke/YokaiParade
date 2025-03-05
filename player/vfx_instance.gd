extends Node2D
var anim_sprite
var rigid_body

func play(animation_name, emit_in_global = false, freeze_physics = false):
	rigid_body = $RigidBody2D
	anim_sprite = $RigidBody2D/AnimatedSprite2D
	anim_sprite.play(animation_name, 1.0, false)
	if emit_in_global: reparent(get_tree().root)
	rigid_body.freeze = freeze_physics


func _physics_process(delta):
	if scale.y == 1 && rotation == 0: return

	scale.y = 1
	rotation = 0


func on_animation_finished():
	queue_free()
	pass
