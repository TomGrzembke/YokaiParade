extends Area2D


func on_checkpoint_area_entered(other):
	if !other.has_method("on_reached_checkpoint"): return

	other.on_reached_checkpoint(%SpawnPoint.global_position)
	%AnimationPlayer.play("active")
	%AudioStreamPlayer2D.play()
	set_deferred("monitoring", false)
