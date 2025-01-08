extends StaticBody2D


func _on_take_damage_area_area_entered(area: Area2D) -> void:
	queue_free()
