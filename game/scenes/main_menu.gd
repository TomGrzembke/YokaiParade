extends GameStateScene


var in_game_state
var options_game_state
var credits_game_state


func _ready():
	%StartButton.pressed.connect(switch_to_in_game_state)
	%OptionsButton.pressed.connect(switch_to_options_game_state)
	%CreditsButton.pressed.connect(switch_to_credits_game_state)
	%QuitButton.pressed.connect(quit_game)


func switch_to_in_game_state():
	switch_to_next_state(in_game_state)


func switch_to_options_game_state():
	switch_to_next_state(options_game_state)


func switch_to_credits_game_state():
	switch_to_next_state(credits_game_state)


func switch_to_next_state(next_game_state):
	%AnimationPlayer.stop()
	%AnimationPlayer.play("fade_out")
	await %AnimationPlayer.animation_finished
	scene_finished.emit(next_game_state)


func quit_game():
	%AnimationPlayer.stop()
	%AnimationPlayer.play("fade_out")
	await %AnimationPlayer.animation_finished
	get_tree().quit()


func set_in_game_state(state):
	in_game_state = state


func set_options_game_state(state):
	options_game_state = state


func set_credits_game_state(state):
	credits_game_state = state
