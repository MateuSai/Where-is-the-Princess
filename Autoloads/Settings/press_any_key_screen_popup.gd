extends Popup

signal input_received(event: InputEvent)

func _ready() -> void:
	get_tree().root.size_changed.connect(func() -> void:
		if visible:
#			var screen_size: Vector2 = get_tree().get_root().size
#			var set_width: float = ProjectSettings.get("display/window/size/viewport_width")
#			var set_height: float = ProjectSettings.get("display/window/size/viewport_height")
#			var real_size: Vector2 = Vector2(size) * screen_size / Vector2(set_width, set_height)
#			position = Vector2(get_tree().root.size)/2 - real_size/2
#			print(Vector2(get_tree().root.size)/2 - real_size/2)
			var t: Transform2D=get_tree().root.get_final_transform()
			var scale: Vector2=t.get_scale()
			position=- t.origin / scale + Vector2(get_tree().root.size) / scale / 2 - Vector2(size) / 2
	)

func _input(event: InputEvent) -> void:
	input_received.emit(event)
