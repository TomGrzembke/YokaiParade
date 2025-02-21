extends RayCast2D

signal ray_entered

func _process(_delta):
	if !is_colliding(): return

	ray_entered.emit()


func has_target():
	return is_colliding()

func get_target():
	if !has_target(): return null
	return get_collider()
