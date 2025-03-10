extends EnemyState


@export_category("Components")
@export var attack_melee_component: Node2D

var recovery_timer


func enter(p_previous_state):
	super.enter(p_previous_state)

	attack_melee_component.set_deal_damage_active(false)
	visualisation_component.enter_state_recovering()

	recovery_timer = get_tree().create_timer(parent.get_recovery_time())
	recovery_timer.timeout.connect(func(): parent.set_is_recovering(false))


func exit():
	attack_melee_component.set_deal_damage_active(true)


func physics_process(_delta):
	if not parent.get_is_recovering():
		return parent.get_initial_state()
