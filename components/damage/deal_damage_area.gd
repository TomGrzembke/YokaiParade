extends "res://components/damage/damage_area.gd"


signal deal_damage_area_entered(target)
signal deal_damage_area_exited(target)


func on_deal_damage_area_entered(source):
	if not source.has_method("get_damage_subject"):
		return

	var subject = get_damage_subject()
	var source_subject = source.get_damage_subject()

	if subject == null \
	or subject == source \
	or subject == source_subject:
		return

	if source != null \
	and source.has_method("deal_damage_area_entered_take_damage_area"):
		deal_damage_area_entered.emit(source)
		source.deal_damage_area_entered_take_damage_area(self)


func on_deal_damage_area_exited(source):
	var subject = get_damage_subject()
	var source_subject = source.get_damage_subject()

	if subject == null \
	or subject == source \
	or subject == source_subject:
		return

	if source != null \
	and source.has_method("deal_damage_area_exited_take_damage_area"):
		deal_damage_area_exited.emit(source)
		source.deal_damage_area_exited_take_damage_area(self)
