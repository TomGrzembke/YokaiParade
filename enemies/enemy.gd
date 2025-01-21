extends RigidBody2D

signal enemy_died()

@export var resource: Resource

func caught():
	enemy_died.emit()
	queue_free()
	return resource
