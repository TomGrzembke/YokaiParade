extends GameStateScene


var previous_state


func _ready():
	%BackButton.pressed.connect(switch_to_previous_state)


func switch_to_previous_state():
	%AnimationPlayer.stop()
	%AnimationPlayer.play("fade_out")
	await %AnimationPlayer.animation_finished
	scene_finished.emit(previous_state)


func set_previous_state(state):
	previous_state = state
