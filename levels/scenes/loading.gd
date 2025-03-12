extends Node


const PROGRESS_BAR_LERP_SPEED_FACTOR = 1.0

var state_node
var progress = 0.0
var has_progress_animation_finished = false
var has_loading_finished = false


func _ready():
	if OS.has_feature("web"):
		%AnimatedCharacter.visible = false
	await %AnimationPlayer.animation_finished
	if state_node != null:
		await state_node.load_level()


func _process(delta):
	update_progress_percent(delta)


func get_progress_percent():
	return progress * 100.0


func update_progress_percent(_delta):
	%ProgressBar.value = move_toward(%ProgressBar.value, get_progress_percent(), PROGRESS_BAR_LERP_SPEED_FACTOR)

	if %ProgressBar.value == 100.0 \
	and not has_progress_animation_finished:
		has_progress_animation_finished = true
		check_change_to_next_level()


func update_progress(p_progress):
	# Loader can set progress back to 0.0 after loading, so we skip updating once we reached 1.0
	if has_loading_finished:
		return

	progress = p_progress

	if progress == 1.0:
		has_loading_finished = true


func check_change_to_next_level():
	if has_loading_finished and has_progress_animation_finished:
		change_to_next_level_state()


# Level States

func set_state_node(node):
	state_node = node


func change_to_next_level_state():
	%AnimationPlayer.play("loading_finished")
	%AnimationPlayer.queue("state_transitions_long/hide_state_scene")
	await %AnimationPlayer.animation_finished
	state_node.change_to_next_level_state()
