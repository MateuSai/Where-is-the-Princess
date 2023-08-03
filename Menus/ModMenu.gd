class_name ModMenu extends PopupPanel


func _init() -> void:
	content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	size = Vector2(300, 200)


func _ready() -> void:
	var margin_container: MarginContainer = MarginContainer.new()
	#tab_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	margin_container.theme = load("res://Theme.tres")
	add_child(margin_container)

	var mods_list: VBoxContainer = VBoxContainer.new()
	for mod_name in SavedData.mods:
		var mod: Mod = Mod.new(mod_name)
		mods_list.add_child(ModRow.new(mod))
	margin_container.add_child(mods_list)

	popup_centered()

	popup_hide.connect(queue_free)


class ModRow extends HBoxContainer:
	var mod: Mod

	@warning_ignore("shadowed_variable")
	func _init(mod: Mod) -> void:
		self.mod = mod

		var label: Label = Label.new()
		label.text = mod.resource_path
		add_child(label)

		var check_box: CheckBox = CheckBox.new()
		check_box.button_pressed = mod.enabled
		check_box.pressed.connect(func():
			mod.enabled = !mod.enabled
			#print(SavedData.mods.rooms[0].enabled)
		)
		add_child(check_box)
