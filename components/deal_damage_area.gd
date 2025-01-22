extends Area2D


func on_deal_damage_area_entered(other):
	if other != null \
	and other.has_method("take_damage"):
		other.take_damage(self)
