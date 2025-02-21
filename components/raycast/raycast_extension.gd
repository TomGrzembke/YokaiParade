extends RayCast2D

var initial_offset

func _ready():
	initial_offset = target_position.x

func has_target():
	return is_colliding()

func get_target():
	if !has_target(): return null
	return get_collider()

func lookat_direction(target_pos):
	var look_pos = to_local(target_pos)
	target_position = look_pos.normalized() * initial_offset
