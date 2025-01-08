extends RigidBody2D

enum EnemyType {
	AIR = 100,
	FIRE = 200,
	WATER = 300,
}

@export var enemy_type: EnemyType = EnemyType.AIR


func caught():
	queue_free()
	return enemy_type
