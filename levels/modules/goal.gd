extends Area2D


func on_body_entered(body):
	if body.has_method("on_goal_reached"):
		body.on_goal_reached()
