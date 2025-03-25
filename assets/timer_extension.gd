extends Node

var timer
var initial_time


func _init(time):
	set_time_left(time)


func subscribe(method):
	timer.connect(method)


func desubscribe(method):
	timer.disconnect(method)


func set_time_left(time):
	timer = get_tree().create_timer(time)
	initial_time = time


func has_time_left():
	return timer.time_left != 0


func get_time_went_by():
	return initial_time - timer.time_left


func get_progress_percent():
	return 1.0 - timer.time_left / initial_time


func get_inverted_progress_percent():
	return timer.time_left / initial_time
