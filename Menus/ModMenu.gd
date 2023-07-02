class_name ModMenu extends PopupPanel


func _init() -> void:
	content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	size = Vector2(300, 200)


func _ready() -> void:
	var tab_container: TabContainer = TabContainer.new()
	#tab_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(tab_container)

	var rooms_tab: VBoxContainer = VBoxContainer.new()
	rooms_tab.name = tr_n("Room", "Rooms", SavedData.mods.rooms.size())
	for room_mod in SavedData.mods.rooms:
		rooms_tab.add_child(ModRow.new(room_mod))
	tab_container.add_child(rooms_tab)

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
