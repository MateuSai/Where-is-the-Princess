class_name KeybindingRow extends ButtonWithSound

signal key_selected()

var action_name: String

var key_texture: KeyIcon


@warning_ignore("shadowed_variable")
func _init(action_name: String) -> void:
	self.action_name = action_name

	custom_minimum_size.y = 24

	var container: HBoxContainer = HBoxContainer.new()
	container.name = "HBoxContainer"
	container.anchor_left = 0.02
	container.anchor_top = 0.02
	container.anchor_right = 0.98
	container.anchor_bottom = 0.98

	var name_label: Label = Label.new()
	name_label.text = action_name.to_upper()
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	container.add_child(name_label)

#	var control: Control = Control.new()
#	control.size_flags_horizontal = SIZE_EXPAND
#	control.size_flags_stretch_ratio = 10
#	container.add_child(control)

	key_texture = KeyIcon.new()
	key_texture.action_name = action_name
	container.add_child(key_texture)

	add_child(container)
	pressed.connect(_on_pressed)


func _ready() -> void:
	super()

	set_process_input(false)



func _input(event: InputEvent) -> void:
	Log.debug(event.as_text())
	if _is_valid_event(event):
		Log.debug("Valid event")
		if Globals.mode == Globals.Mode.MOUSE:
			var controller_event: InputEvent = InputMap.action_get_events(action_name)[1]
			InputMap.action_erase_events(action_name)
			InputMap.action_add_event(action_name, event)
			InputMap.action_add_event(action_name, controller_event)
			#Settings.settings.key_bindings[action_name]["keyboard"] = event

			key_texture.update_texture_with_event_text(event.as_text())
		else: # Estamos usando mando
			var keyboard_event: InputEvent = InputMap.action_get_events(action_name)[0]
			InputMap.action_erase_events(action_name)
			InputMap.action_add_event(action_name, keyboard_event)
			InputMap.action_add_event(action_name, event)
			#Settings.settings.key_bindings[action_name]["controller"] = event

			key_texture.update_texture_with_event_text(Globals.get_joypad_event_image_id(event))

		set_process_input(false)

		get_viewport().set_input_as_handled()

		key_selected.emit()


func _is_valid_event(e: InputEvent) -> bool:
	if e.as_text().contains("(Double Click)"):
		return false

	if Globals.mode == Globals.Mode.MOUSE:
		return (e is InputEventKey and Globals.INPUT_IMAGE_RECTS.has(e.as_text().to_lower())) or (e is InputEventMouseButton and ((e as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT or (e as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT or (e as InputEventMouseButton).button_index == MOUSE_BUTTON_MIDDLE or (e as InputEventMouseButton).button_index == MOUSE_BUTTON_WHEEL_DOWN or (e as InputEventMouseButton).button_index == MOUSE_BUTTON_WHEEL_UP))
	else: # estamos usando mando
		return ((e is InputEventJoypadButton or (e is InputEventJoypadMotion and e.as_text().contains("Trigger"))) and Globals.INPUT_IMAGE_RECTS.has(Globals.get_joypad_event_image_id(e)))


func _on_pressed() -> void:
	set_process_input(true)
