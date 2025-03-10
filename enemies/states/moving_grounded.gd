extends EnemyStateCatchable


@export_category("Enemy States")
@export var attacking_melee_enemy_state: EnemyState
@export var lunging_enemy_state: EnemyState

@export_category("Components")
@export var cliff_detection_component: Node2D
@export var target_direction_component: Node2D
@export var attack_melee_component: Node2D
@export var attack_ranged_component: Node2D

var speed = 0.0


func init(p_parent):
	super(p_parent)

	speed = parent.get_speed()


func enter(p_previous_state):
	super.enter(p_previous_state)

	visualisation_component.enter_state_moving()


func physics_process(delta):
	handle_gravity(delta)
	update_direction()

	parent.velocity = Vector2(visualisation_component.get_facing_direction().x * speed, parent.velocity.y)
	visualisation_component.set_facing_direction(parent.velocity.normalized())
	parent.move_and_slide()

	var next_state = check_caught()

	if next_state != null:
		return next_state

	if attack_melee_component.get_target_in_range() != null:
		next_state = attacking_melee_enemy_state
	elif attack_ranged_component.get_target_in_visible_range() != null:
		next_state = lunging_enemy_state

	return next_state


func handle_gravity(delta):
	if not parent.is_on_floor():
		parent.velocity += parent.get_gravity() * delta


func update_direction():
	var current_direction = visualisation_component.get_facing_direction()
	var target_direction = target_direction_component.get_target_direction()
	var new_direction

	if current_direction != null:
		if parent.is_on_wall():
			new_direction = Vector2(current_direction.x * -1.0, current_direction.y).normalized()

		elif cliff_detection_component.is_on_cliff_right():
			new_direction = Vector2(-1.0, current_direction.y).normalized()

		elif cliff_detection_component.is_on_cliff_left():
			new_direction = Vector2(1.0, current_direction.y).normalized()

	if target_direction != null \
	and target_direction != Vector2.ZERO:
		new_direction = Vector2(target_direction.x, 0.0).normalized()

	if new_direction == null: return

	visualisation_component.set_facing_direction(new_direction)
