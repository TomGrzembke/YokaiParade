extends State


var previous_state
var recovery_timer
var recovering = true


func enter(p_previous_state):
	self.previous_state = p_previous_state

	if previous_state == null:
		printerr("Error: Recovering state should have a previous state!")
		return

	parent.set_is_getting_caught(false)
	parent.set_deal_damage_active(false)
	parent.enter_animation_state_recovering()

	recovery_timer = get_tree().create_timer(parent.get_recovery_time())
	recovery_timer.timeout.connect(func(): recovering = false)


func exit():
	parent.set_deal_damage_active(true)
	reset_recovering_state()


func physics_process(_delta):
	if not recovering:
		return previous_state


func reset_recovering_state():
	recovering = true
