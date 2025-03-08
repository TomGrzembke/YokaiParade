extends Node2D


func _ready():
	assert(get_node_or_null("RightCliffDetectionRayCast") != null, "Cliff detection component at %s is missing RightCliffDetectionRayCast child that determines the detection area." % get_path())
	assert(get_node_or_null("LeftCliffDetectionRayCast") != null, "Cliff detection component at %s is missing LeftCliffDetectionRayCast child that determines the detection area." % get_path())


func is_on_cliff_right():
	return not $RightCliffDetectionRayCast.is_colliding()


func is_on_cliff_left():
	return not $LeftCliffDetectionRayCast.is_colliding()
