extends Line2D

const MAX_POINTS : int = 2000
@export var trail_points_max = 4

func _ready():
	points.clear()


func _physics_process(_delta):
	add_point(get_parent().global_position)
	if get_point_count() > trail_points_max:
		remove_point(0)
