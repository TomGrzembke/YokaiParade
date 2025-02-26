extends EnemyStateCatchable


@export var lunging_state: EnemyState

var speed = 0.0


func init(p_parent):
	super(p_parent)

	speed = parent.get_speed()


func enter(p_previous_state):
	super.enter(p_previous_state)

	state_animations_scene.enter_state_moving()


func physics_process(delta):
	parent.handle_gravity(delta)
	update_direction()

	parent.velocity = Vector2(parent.get_look_direction().x * speed, parent.velocity.y)
	parent.set_look_direction(parent.velocity.normalized())
	parent.move_and_slide()

	var next_state = check_caught()

	if next_state == null \
	and parent.get_target_in_perception_area() != null:
		next_state = lunging_state

	return next_state


func update_direction():
	var direction = parent.get_look_direction()
	if direction != null:
		if parent.is_on_wall() \
		or parent.is_on_cliff():
			parent.set_look_direction(Vector2(direction.x * -1.0, direction.y).normalized())
