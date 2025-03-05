extends Sprite2D


@export var controller_variant : Texture2D
var keyboard_variant


func _ready():
	keyboard_variant = texture


func _unhandled_input(event):
	if Input.get_connected_joypads().size() == 0:
		texture = keyboard_variant
	else:
		texture = controller_variant
	
