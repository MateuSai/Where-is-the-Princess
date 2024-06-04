class_name KeyIcon extends TextureRect

const TILE_ICONS_FOLDER: String = "res://Art/kenney_input-prompts-pixel-16/Tiles/"

@export var action_name: String

func _init() -> void:
	stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	size_flags_horizontal = SIZE_EXPAND|SIZE_SHRINK_END
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	texture = AtlasTexture.new()
	(texture as AtlasTexture).atlas = preload ("res://Art/kenney_input-prompts-pixel-16/Tilemap/tilemap_packed.png")

	# warning-ignore:return_value_discarded
	draw.connect(_on_draw)
	# warning-ignore:return_value_discarded
	hidden.connect(_on_hide)

# Porque se llama 2 veces esta wea? Quiza cuando cambio la texture se llama _draw automaticamente
func _on_draw() -> void:
	# print("_on_draw_called")
	if not Globals.mode_changed.is_connected(update_texture):
		# warning-ignore:return_value_discarded
		Globals.mode_changed.connect(update_texture)
	update_texture(Globals.mode)

func _on_hide() -> void:
	if Globals.mode_changed.is_connected(update_texture):
		Globals.mode_changed.disconnect(update_texture)

func update_texture(mode: int) -> void:
	if mode == Globals.Mode.MOUSE:
		(texture as AtlasTexture).region = KeyIcon.get_key_region(InputMap.action_get_events(action_name)[0].as_text())
	else:
		(texture as AtlasTexture).region = KeyIcon.get_key_region(Globals.get_joypad_event_image_id(InputMap.action_get_events(action_name)[1]))

static func get_key_region(text: String) -> Rect2:
	# print(text)
	if text.begins_with("InputEventMouseButton : button_index=BUTTON_MIDDLE"):
		text = "mouse_middle"
	elif text.begins_with("InputEventMouseButton : button_index=BUTTON_WHEEL_DOWN"):
		text = "mouse_wheel_down"
	elif text.begins_with("InputEventMouseButton : button_index=BUTTON_WHEEL_UP"):
		text = "mouse_wheel_up"
	elif text.begins_with("InputEventMouseButton : button_index=BUTTON_LEFT"):
		text = "mouse_left"
	elif text.begins_with("InputEventMouseButton : button_index=BUTTON_RIGHT"):
		text = "mouse_right"

	return Globals.INPUT_IMAGE_RECTS[text.to_lower().replace(" ", "_")]
