extends Area2D


signal took_damage(source)


func take_damage(source):
	took_damage.emit(source)
