extends Node2D


var target_in_range


func _ready():
	assert(get_node_or_null("DealDamageArea") != null, "Ranged attack component at %s is missing DealDamageArea child." % get_path())

	$DealDamageArea.deal_damage_area_entered.connect(on_deal_damage_area_entered)
	$DealDamageArea.deal_damage_area_exited.connect(on_deal_damage_area_exited)


func get_target_in_visible_range():
	if target_in_range == null: return

	if is_target_obstructed(target_in_range):
		return null

	return target_in_range


func update_target_position(target):
	%ObstructionRayCast.target_position = to_local(target.global_position)


func is_target_obstructed(target):
	update_target_position(target)
	%ObstructionRayCast.force_raycast_update()
	return %ObstructionRayCast.is_colliding()


func on_deal_damage_area_entered(target):
	if target == null: return

	%ObstructionRayCast.enabled = true

	target_in_range = $DealDamageArea.get_damageable_subject(target)


func on_deal_damage_area_exited(_target):
	%ObstructionRayCast.enabled = false

	target_in_range = null
