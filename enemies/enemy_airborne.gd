extends PathFollow2D


signal enemy_caught(enemy)


@export var initial_state: State
@export var max_speed = 150.0
@export var recovery_time = 3.0
@export var easing_curve: Curve
@export var element_type: EnemyElementType

var is_getting_caught = false


func _ready():
	if element_type != null:
		%MeshInstance2D.modulate = element_type.get_color()

	%StateMachine.init(self, initial_state)


func _unhandled_input(event):
	%StateMachine.unhandled_input(event)


func _physics_process(delta):
	%StateMachine.physics_process(delta)


func _process(delta):
	%StateMachine.process(delta)


func set_deal_damage_active(active):
	%DealDamageArea.set_deferred("monitoring", active)


func set_is_getting_caught(status):
	is_getting_caught = status


func get_is_getting_caught():
	return is_getting_caught


func get_recovery_time():
	return recovery_time


func get_is_path_closed():
	var path = get_parent()
	if path == null \
	and path:
		return

	if path.curve.get_point_position(0) == path.curve.get_point_position(path.curve.point_count - 1):
		return true

	return false


func get_path_length():
	return get_parent().curve.get_baked_length()


func set_alpha(alpha):
	var color = %Sprite2D.modulate
	color.a = alpha
	%Sprite2D.modulate = color


func got_caught(_source):
	enemy_caught.emit(self)
	is_getting_caught = true

	if element_type == null:
		return null
	return element_type.spawning_ability
