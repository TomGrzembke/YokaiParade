extends Node2D

@export_range(0, 100, 1) var idle2_probability : float
@export var idle_animations : Dictionary = {"idling" : 70, "idling2": 20, "idling3": 10}
@onready var player: CharacterBody2D = $".."
@onready var abilities: Node2D = $"../Abilities"
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var state_machine

func _ready():
	state_machine = animation_tree.get("parameters/playback")
	abilities.player_hits.connect(func(): state_machine.start("hit"))
	abilities.used_ability.connect(func(): state_machine.start("dash"))

	player.player_despawned.connect(func(): state_machine.start("dying"))
	player.player_gets_pushed.connect(func(): state_machine.start("got_hit"))


func _on_animation_finished(anim_name):
	different_idles(anim_name)


func different_idles(anim_name):
	if !anim_name in idle_animations: return

	var rng_percent = randi_range(0, 100)
	print(rng_percent)

	for key in idle_animations.keys():
		var value = idle_animations[key]
		if value > rng_percent:
			continue

		state_machine.start(key, true)
		print(key)
		return
