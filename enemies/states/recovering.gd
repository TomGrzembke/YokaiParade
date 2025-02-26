extends EnemyState


var recovery_timer


func enter(p_previous_state):
	super.enter(p_previous_state)

	if previous_state == null:
		printerr("Error: Recovering state should have a previous state!")
		return

	parent.set_deal_bump_damage_active(false)
	state_animations_scene.enter_state_recovering()

	recovery_timer = get_tree().create_timer(parent.get_recovery_time())
	recovery_timer.timeout.connect(func(): parent.set_is_recovering(false))


func exit():
	parent.set_deal_bump_damage_active(true)


func physics_process(_delta):
	if not parent.get_is_recovering():
		return previous_state
