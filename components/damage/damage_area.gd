extends Area2D


func get_damage_subject():
	return get_parent()


func get_damageable_subject(target):
	if not target.has_method("get_damage_subject"):
		return null

	var subject = target.get_damage_subject()

	if subject == null \
	or not subject.has_method("on_took_damage"):
		return null

	return subject
