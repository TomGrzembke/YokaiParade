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
	parent.set_alpha(0.1)

	recovery_timer = get_tree().create_timer(parent.get_recovery_time())
	recovery_timer.timeout.connect(func(): recovering = false)


func exit():
	parent.set_deal_damage_active(true)
	parent.set_alpha(1.0)
	recovering = true


func physics_process(_delta):
	if not recovering:
		return previous_state
