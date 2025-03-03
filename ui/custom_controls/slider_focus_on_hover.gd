extends Slider


func _ready():
	mouse_entered.connect(func ():
		grab_focus()
	)
