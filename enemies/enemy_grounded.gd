extends CharacterBody2D


enum Direction {
	LEFT = -1,
	RIGHT = 1,
}

@export var speed = 100.0
@export var initial_direction = Direction.RIGHT

var direction


func _ready():
	direction = initial_direction


func _physics_process(delta):
	handle_gravity(delta)
	handle_turn()
	handle_movement(delta)

	move_and_slide()


func handle_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta


func handle_turn():
	if direction:
		if is_on_wall() \
		or is_on_cliff():
			flip_horizontally()


func handle_movement(_delta):
	velocity.x = direction * speed


func flip_horizontally():
	direction *= -1.0
	scale.x *= -1.0


func is_on_cliff():
	return not %RayCast2D.is_colliding()


func on_despawn():
	queue_free()
