extends Node2D

@export var trail_points_max = 4
@onready var flip_line: Line2D = $"../AttackLine"


func _process(_delta):
	update_trail()
	flip()


func update_trail():
	flip_line.add_point(global_position - flip_line.global_position)

	if flip_line.get_point_count() > trail_points_max:
		flip_line.remove_point(0)


func flip():
	flip_line.scale.x = $"../..".look_direction
