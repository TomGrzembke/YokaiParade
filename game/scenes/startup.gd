extends GameStateScene


var next_game_state


func _ready():
	await %AnimationPlayer.animation_finished
	scene_finished.emit(next_game_state)


func set_title_game_state(state):
	next_game_state = state
