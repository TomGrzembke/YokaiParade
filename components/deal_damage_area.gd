extends Area2D


signal deal_damage_area_entered(target)
signal deal_damage_area_exited(target)


func on_deal_damage_area_entered(source):
	var parent = get_parent()
	var source_parent = source.get_parent()

	if parent == null \
	or parent == source \
	or parent == source_parent:
		return

	if source != null \
	and source.has_method("deal_damage_area_entered_take_damage_area"):
		deal_damage_area_entered.emit(source)
		source.deal_damage_area_entered_take_damage_area(self)


func on_deal_damage_area_exited(source):
	var parent = get_parent()
	var source_parent = source.get_parent()

	if parent == null \
	or parent == source \
	or parent == source_parent:
		return

	if source != null \
	and source.has_method("deal_damage_area_exited_take_damage_area"):
		deal_damage_area_exited.emit(source)
		source.deal_damage_area_exited_take_damage_area(self)
