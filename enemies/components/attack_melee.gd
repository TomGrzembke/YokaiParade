extends Node2D


var target_in_range


func _ready():
	assert(get_node_or_null("DealDamageArea") != null, "Melee attack component at %s is missing DealDamageArea child." % get_path())

	$DealDamageArea.deal_damage_area_entered.connect(on_deal_damage_area_entered)
	$DealDamageArea.deal_damage_area_exited.connect(on_deal_damage_area_exited)


func get_target_in_range():
	return target_in_range


func set_deal_damage_active(active):
	$DealDamageArea.set_deferred("monitoring", active)


func on_deal_damage_area_entered(target):
	if target == null: return

	target_in_range = $DealDamageArea.get_damageable_subject(target)

	if target_in_range == null: return
	target_in_range.on_took_damage(self)


func on_deal_damage_area_exited(_target):
	target_in_range = null
