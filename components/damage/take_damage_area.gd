extends "res://components/damage/damage_area.gd"


signal take_damage_area_entered(source)
signal take_damage_area_exited(source)


func deal_damage_area_entered_take_damage_area(source):
	take_damage_area_entered.emit(source)


func deal_damage_area_exited_take_damage_area(source):
	take_damage_area_exited.emit(source)
