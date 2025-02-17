extends StaticBody2D

const break_animation = "break"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var mesh_instance_2d: MeshInstance2D = $MeshInstance2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var take_damage_area: Area2D = $TakeDamageArea


func took_fire_damage(_source):
	mesh_instance_2d.visible = false
	collision_shape_2d.disabled = true
	animation_player.animation_finished.connect(delete)
	animation_player.play(break_animation)


func delete(animation_name):
	if animation_name != break_animation: return

	queue_free()
