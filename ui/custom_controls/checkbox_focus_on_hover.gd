extends CheckBox

@onready var ui_audio_stream_player_hover = %UiAudioStreamPlayerHover
@onready var ui_audio_stream_player_click = %UiAudioStreamPlayerClick


func _ready():
	mouse_entered.connect(on_hover)
	focus_entered.connect(on_hover)


func _pressed():
	disabled = true
	if ui_audio_stream_player_click != null:
		ui_audio_stream_player_click.play()


func on_hover():
	grab_focus()
	if ui_audio_stream_player_hover != null:
		ui_audio_stream_player_hover.play()


func _exit_tree():
	mouse_entered.disconnect(on_hover)
	focus_entered.disconnect(on_hover)
