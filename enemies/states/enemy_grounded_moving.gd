extends "res://enemies/states/catchable_state.gd"


var speed = 0.0


func init(p_parent):
	super(p_parent)
	speed = parent.get_speed()


func enter(_previous_state):
	parent.enter_animation_state_moving()


func physics_process(delta):
	parent.handle_gravity(delta)
	handle_turn()

	parent.velocity = Vector2(parent.get_direction().x * speed, parent.velocity.y)
	parent.set_direction(parent.velocity.normalized())
	parent.move_and_slide()

	return check_caught()


func handle_turn():
	var direction = parent.get_direction()
	if direction != null:
		if parent.is_on_wall() \
		or parent.is_on_cliff():
			parent.set_direction(Vector2(direction.x * -1.0, direction.y))
			parent.enter_animation_state_moving()
