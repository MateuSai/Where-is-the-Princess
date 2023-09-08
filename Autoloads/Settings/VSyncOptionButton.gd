extends OptionButton


func _ready() -> void:
	add_item("DISABLED")
	add_item("ENABLED")
	add_item("ADAPTATIVE")
	add_item("MAILBOX")
	select(DisplayServer.window_get_vsync_mode())
	item_selected.connect(func(index: int):
		DisplayServer.window_set_vsync_mode(index)
	)
