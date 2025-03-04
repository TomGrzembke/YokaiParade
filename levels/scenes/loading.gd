extends Node


const PROGRESS_BAR_LERP_SPEED_FACTOR = 5.0

var state_node
var progress_percent = 0.0
var loading_finished = false


func _ready():
	await %AnimationPlayer.animation_finished
	await state_node.load_level()


func _process(delta):
	%ProgressBar.value = lerp(%ProgressBar.value, progress_percent, delta * PROGRESS_BAR_LERP_SPEED_FACTOR)


func update_progress(progress):
	# Loader can set progress back to 0.0 after loading, so we skip updating once we reached 1.0
	if loading_finished:
		return

	progress_percent = progress * 100.0

	if progress == 1.0:
		finish_loading()


func finish_loading():
	loading_finished = true
	change_to_next_level_state()


# Level States

func set_state_node(node):
	state_node = node


func change_to_next_level_state():
	%AnimationPlayer.queue("loading_finished")
	%AnimationPlayer.queue("state_transitions_long/hide_state_scene")
	await %AnimationPlayer.animation_finished
	state_node.change_to_next_level_state()
