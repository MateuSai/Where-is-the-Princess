class_name ModMenu extends PopupPanel


func _init() -> void:
	content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	size = Vector2(300, 200)


func _ready() -> void:
	add_theme_stylebox_override("panel", Settings.get("theme_override_styles/panel"))

	var margin_container: MarginContainer = MarginContainer.new()
	#tab_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	margin_container.theme = load("res://Theme.tres")
	margin_container.add_theme_constant_override("margin_left", 4)
	margin_container.add_theme_constant_override("margin_top", 4)
	margin_container.add_theme_constant_override("margin_right", 4)
	margin_container.add_theme_constant_override("margin_bottom", 4)
	add_child(margin_container)

	var mods_list: VBoxContainer = VBoxContainer.new()
	for mod in SavedData.mods:
		mods_list.add_child(ModRow.new(mod))
	margin_container.add_child(mods_list)

	popup_centered()

	popup_hide.connect(func():
		SavedData.save_mods_conf()
		queue_free()
	)


class ModRow extends HBoxContainer:
	var mod: Mod

	@warning_ignore("shadowed_variable")
	func _init(mod: Mod) -> void:
		self.mod = mod

		var check_box: CheckBox = CheckBox.new()
		check_box.button_pressed = mod.enabled
		check_box.pressed.connect(func():
			mod.enabled = !mod.enabled
			#print(SavedData.mods.rooms[0].enabled)
		)
		#check_box.size_flags_horizontal = Control.SIZE_SHRINK_END | Control.SIZE_EXPAND
		add_child(check_box)

		var label: Label = Label.new()
		label.text = mod.get_name()
		add_child(label)

		var spin_box: SpinBox = SpinBox.new()
		spin_box.value = mod.priority
		spin_box.value_changed.connect(func(new_value: int):
			mod.priority = new_value
		)
		add_child(spin_box)
