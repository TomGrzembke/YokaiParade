extends Node
class_name TimerExtension

signal timeout
var tree
var timer
var initial_time

var time_left:
	get: return timer.time_left


var time_went_by:
	get: return get_time_went_by()


var has_time_left:
	get: return get_has_time_left()


func _init(_tree, time):
	tree = _tree
	set_time_left(time)


func set_time_left(time):
	if timer == null:
		timer = tree.create_timer(time)
		timer.timeout.connect(timeout.emit)

	timer.set_time_left(time)
	initial_time = time


func subscribe(method):
	if timeout.is_connected(method): return
	timeout.connect(method)


func unsubscribe(method):
	timeout.disconnect(method)


func get_has_time_left():
	return timer.time_left != 0


func get_time_went_by():
	return initial_time - timer.time_left


func get_progress_percent():
	return 1.0 - timer.time_left / initial_time


func get_inverted_progress_percent():
	return timer.time_left / initial_time
