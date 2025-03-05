extends StaticBody2D


func took_fire_damage(source):
	var animation_name = "break_right"
	if source.global_position.x > %CollisionShape2D.global_position.x:
		animation_name = "break_left"

	%CollisionShape2D.disabled = true
	%TakeDamageArea.monitorable = false
	%TakeDamageArea.monitoring = false

	%AudioStreamPlayer2D.play()
	%AnimatedSprite2D.play(animation_name)

	await %AnimatedSprite2D.animation_finished

	queue_free()
