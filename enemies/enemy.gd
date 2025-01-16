extends RigidBody2D


signal enemy_died()


enum EnemyType {
	AIR = 100,
	FIRE = 200,
	WATER = 300,
}

@export var enemy_type: EnemyType = EnemyType.AIR


func caught():
	enemy_died.emit()
	queue_free()
	return enemy_type
