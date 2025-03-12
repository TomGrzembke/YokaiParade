extends AudioStreamPlayer2D
@export_range(0.0, 2.0) var pitch_min : float = 1.0
@export_range(0.0, 2.0) var pitch_max : float = 1.0


func emit_sound(sound : AudioStream):
	set_stream(sound)
	play()
	pitch_scale = randf_range(pitch_min, pitch_max)
