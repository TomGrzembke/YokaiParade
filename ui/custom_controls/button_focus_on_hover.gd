extends Button

var hover_player
var click_player

func _ready():
	mouse_entered.connect(on_hover)
	focus_entered.connect(on_hover)
	hover_player = get_node_in_game("Game/UiAudioStreamPlayerHover")
	click_player = get_node_in_game("Game/UiAudioStreamPlayerClick")


func _pressed():
	disabled = true
	click_player.play()


func on_hover():
	grab_focus()
	hover_player.play()


func get_node_in_game(node_patch):
	return get_tree().root.get_node(node_patch)


func _exit_tree():
	mouse_entered.disconnect(on_hover)
	focus_entered.disconnect(on_hover)
