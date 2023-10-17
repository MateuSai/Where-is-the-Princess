class_name AutoFreeSound extends AudioStreamPlayer2D


@warning_ignore("shadowed_variable_base_class")
func start(stream: AudioStream, at_pos: Vector2, volume_db: float = 0.0, max_distance: int = 300) -> void:
	self.stream = stream
	self.bus = "Sounds"
	self.position = at_pos
	self.volume_db = volume_db
	self.max_distance = max_distance

	finished.connect(queue_free)
	play()
