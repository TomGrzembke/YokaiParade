extends RayCast2D

signal ray_entered

func _process(delta):
	if !is_colliding(): return

	ray_entered.emit()

func has_target():
	return is_colliding()
