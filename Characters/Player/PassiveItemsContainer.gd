extends HFlowContainer


@onready var player: Player = owner


func _ready() -> void:
	player.permanent_passive_item_picked_up.connect(_on_player_permanent_passive_item_picked_up)
	player.temporal_passive_item_picked_up.connect(_on_player_temporal_passive_item_picked_up)
	player.temporal_passive_item_unequiped.connect(_on_player_temporal_passive_item_unequiped)


func _on_player_permanent_passive_item_picked_up(item: PermanentPassiveItem) -> void:
	var texture_rect: PassiveItemIcon = PassiveItemIcon.new()
	texture_rect.item = item
	texture_rect.texture = item.get_icon()
	add_child(texture_rect)


func _on_player_temporal_passive_item_picked_up(item: TemporalPassiveItem) -> void:
	var item_class_name: String = (item.get_script() as Script).get_path().get_file().trim_suffix(".gd")
	var temporal_passive_item_icon: TemporalPassiveItemIcon = get_node_or_null(item_class_name)
	if temporal_passive_item_icon:
		temporal_passive_item_icon.add()
	else:
		temporal_passive_item_icon = TemporalPassiveItemIcon.new()
		# print(item.get_script().get_path().get_file().trim_suffix(".gd"))
		temporal_passive_item_icon.name = item_class_name
		temporal_passive_item_icon.item = item
		temporal_passive_item_icon.texture = item.get_icon()
		add_child(temporal_passive_item_icon)


func _on_player_temporal_passive_item_unequiped(item: TemporalPassiveItem) -> void:
	(get_node((item.get_script() as Script).get_path().get_file().trim_suffix(".gd")) as TemporalPassiveItemIcon).remove()


class PassiveItemIcon extends TextureRect:
	var item: Item

	var pause_menu_open: bool = false

	func _init() -> void:
		theme = load("res://SmallFontTheme.tres")
		modulate.a = 0.6

	#func _ready() -> void:
		process_mode = Node.PROCESS_MODE_WHEN_PAUSED

		Globals.pause_menu_opened.connect(func() -> void:
			z_index = 100
			modulate.a = 1.0
			pause_menu_open = true
		)
		Globals.pause_menu_closed.connect(func() -> void:
			z_index = 0
			modulate.a = 0.6
			pause_menu_open = false
		)

	func _get_tooltip(_at_position: Vector2) -> String:
		if pause_menu_open:
			return item.get_item_name() + "\n\n" + item.get_item_description()
		else:
			return ""


class TemporalPassiveItemIcon extends PassiveItemIcon:
	var amount: int = 1

	var label: Label

	func _init() -> void:
		label = Label.new()
		label.set_anchors_preset(Control.PRESET_TOP_LEFT)
		label.offset_left = 0
		label.offset_right = 0
		label.offset_bottom = 0
		label.offset_top = 0
#		label.add_theme_font_size_override("font_size", 10)
		label.text = "1"
		add_child(label)


	func add() -> void:
		amount += 1
		label.text = str(amount)


	func remove() -> void:
		amount -= 1
		if amount == 0:
			queue_free()
		else:
			label.text = str(amount)
