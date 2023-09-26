class_name AutoFreeSound extends AudioStreamPlayer2D


@warning_ignore("shadowed_variable_base_class")
func start(stream: AudioStream, bus: String, at_pos: Vector2, volume_db: float = 0.0) -> void:
	self.stream = stream
	self.bus = bus
	self.position = at_pos
	self.volume_db = volume_db

	finished.connect(queue_free)
	play()
