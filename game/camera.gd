extends Camera2D

@export var offset_value : Vector2
@export var lerp_speed : float
@export var smooth_curve : Curve

var current_offset
var position_cache
var lerp_time = 0.0
var cached_direction = -1


func _ready():
	position_cache = position
	current_offset = offset_value


func _physics_process(delta):
	look_offset(delta)


func look_offset(delta):
	var current_direction = sign(position.x - position_cache.x)

	if current_direction == 0:
		current_direction = cached_direction

	elif current_direction != cached_direction:
		cached_direction = current_direction
		current_offset.x = current_direction * offset_value.x
		lerp_time = 0


	offset = offset.lerp(current_offset, smooth_curve.sample(delta * lerp_speed * lerp_time))
	lerp_time += delta
	position_cache = position
