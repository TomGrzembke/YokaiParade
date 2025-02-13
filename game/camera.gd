extends Camera2D

@export var offset_value : Vector2
@export var lerp_speed : float
@export var minimum_change_distance : float = 420
@export var smooth_curve : Curve

var current_offset
var position_cache
var lerp_time = 0.0
var cached_direction = -1
var distance_since_flipped = 0.0
var flipped_last_position = Vector2(0,0)

func _ready():
	initialize_caching()


func _physics_process(delta):
	look_offset(delta)


func initialize_caching():
	position_cache = position
	cached_direction = sign(position.x - position_cache.x)
	current_offset = offset_value


func look_offset(delta):
	var current_direction = sign(position.x - position_cache.x)

	calc_distance_flip(current_direction)

	calc_offset(current_direction)

	adjust_offset(delta)


func calc_distance_flip(current_direction):
	if current_direction != cached_direction:
		distance_since_flipped = position.x - flipped_last_position.x

	elif current_direction == cached_direction:
		flipped_last_position = position
		distance_since_flipped = 0.0


func calc_offset(current_direction):
	if current_direction == 0:
		current_direction = cached_direction

	if current_direction != cached_direction && abs(distance_since_flipped) > minimum_change_distance:
		cached_direction = current_direction
		current_offset.x = offset_value.x * current_direction
		lerp_time = 0


func adjust_offset(delta):
	offset = offset.lerp(current_offset, smooth_curve.sample(delta * lerp_speed * lerp_time))
	lerp_time += delta
	position_cache = position
