extends OptionButtonWithSound


func _ready() -> void:
	super()

	add_item("DISABLED")
	add_item("ENABLED")
	add_item("ADAPTIVE")
	#add_item("MAILBOX")
	select(DisplayServer.window_get_vsync_mode())
	item_selected.connect(func(index: int) -> void:
		DisplayServer.window_set_vsync_mode(index)
	)
