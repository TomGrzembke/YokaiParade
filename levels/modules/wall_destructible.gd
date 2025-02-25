extends StaticBody2D


const BREAK_ANIMATION = "break"


func _ready():
	if get_node_or_null("%AnimationPlayer") != null:
		%AnimationPlayer.animation_finished.connect(delete)


func took_fire_damage(_source):
	%CollisionShape2D.disabled = true
	%AnimationPlayer.play(BREAK_ANIMATION)


func delete(animation_name):
	if animation_name != BREAK_ANIMATION: return

	queue_free()
