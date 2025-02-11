extends State


var previous_state
var recovery_timer


func enter(p_previous_state):
	self.previous_state = p_previous_state

	if previous_state == null:
		printerr("Error: Recovering state should have a previous state!")
		return

	parent.set_deal_damage_active(false)
	parent.enter_animation_state_recovering()

	recovery_timer = get_tree().create_timer(parent.get_recovery_time())
	recovery_timer.timeout.connect(func(): parent.set_is_recovering(false))


func exit():
	parent.set_deal_damage_active(true)


func physics_process(_delta):
	if not parent.get_is_recovering():
		return previous_state
