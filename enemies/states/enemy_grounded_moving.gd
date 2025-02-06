extends "res://enemies/states/catchable_state.gd"


var speed = 0.0


func init(p_parent):
	super(p_parent)
	speed = parent.speed


func physics_process(delta):
	handle_gravity(delta)
	parent.handle_turn()
	parent.velocity.x = parent.direction * speed

	parent.move_and_slide()

	return check_caught()


func handle_gravity(delta):
	if not parent.is_on_floor():
		parent.velocity += parent.get_gravity() * delta
