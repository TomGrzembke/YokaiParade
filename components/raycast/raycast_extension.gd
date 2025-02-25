extends RayCast2D


func has_target():
	return is_colliding()


func get_target():
	if !has_target(): return null
	return get_collider()


func lookat_direction(target_pos):
	var look_pos = to_local(target_pos)
	target_position = look_pos.normalized() * target_position.length()

func lookat_position(target_pos):
	target_position = to_local(target_pos)
