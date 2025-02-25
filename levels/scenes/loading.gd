extends Node


signal level_loading_ready


var state_node


func _ready():
	%StartButton.pressed.connect(change_to_next_level_state)
	await %AnimationPlayer.animation_finished
	await state_node.load_level()
	%StartButton.grab_focus()


func set_start_button_enabled(enabled):
	%StartButton.disabled = not enabled

func update_progress_bar(progress):
	%ProgressBar.value = progress * 100


# Level States

func set_state_node(node):
	state_node = node


func change_to_next_level_state():
	%AnimationPlayer.stop()
	%AnimationPlayer.play("state_transitions_long/hide_state_scene")
	await %AnimationPlayer.animation_finished
	state_node.change_to_next_level_state()


func emit_level_loading_ready_signal():
	level_loading_ready.emit()
