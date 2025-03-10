class_name EnemyState
extends State

@export var visualisation_component: Node2D

func enter(p_previous_state):
	super.enter(p_previous_state)

	visualisation_component.set_state_node(self)
