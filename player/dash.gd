extends Node2D

@export var fire_power_dash_velocity = 300.0
@export var fire_power_dash_duration = 1.0


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass

func use():
	return
	#is_dashing = true
	#velocity.y = 0.0
	#velocity.x = fire_power_dash_velocity * dash_direction
	#%DashTimer.wait_time = fire_power_dash_duration
	#%DashTimer.start()
	#await %DashTimer.timeout
	#is_dashing = false
