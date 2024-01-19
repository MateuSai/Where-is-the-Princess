class_name UpgradesContainer extends HFlowContainer


func _ready() -> void:
	await (get_tree().current_scene as Game).player_added

	var player_upgrades: Array[PlayerUpgrade] = SavedData.data.player_upgrades

	for player_upgrade: PlayerUpgrade in player_upgrades:
		var item_class_name: String = (player_upgrade.get_script() as Script).get_path().get_file().trim_suffix(".gd")
		var icon: PlayerUpgradeItemIcon = PlayerUpgradeItemIcon.new()
		icon.show_tooltip = true
		icon.name
		icon.item = player_upgrade
		icon.texture = player_upgrade.get_icon()
		add_child(icon)
		for i: int in player_upgrade.amount - 1:
			icon.add()

	Globals.player.player_upgrade_item_picked_up.connect(func(item: PlayerUpgrade) -> void:
		var item_class_name: String = (item.get_script() as Script).get_path().get_file().trim_suffix(".gd")
		var player_upgrade_item_icon: PlayerUpgradeItemIcon = get_node_or_null(item_class_name)
		if player_upgrade_item_icon:
			player_upgrade_item_icon.add()
		else:
			player_upgrade_item_icon = PlayerUpgradeItemIcon.new()
			player_upgrade_item_icon.show_tooltip = true
			# print(item.get_script().get_path().get_file().trim_suffix(".gd"))
			player_upgrade_item_icon.name = item_class_name
			player_upgrade_item_icon.item = item
			player_upgrade_item_icon.texture = item.get_icon()
			add_child(player_upgrade_item_icon)
	)


class PlayerUpgradeItemIcon extends ItemsContainer.PassiveItemIcon:
	var amount: int = 1

	var label: Label

	func _init() -> void:
		label = Label.new()
		label.theme = load("res://SmallFontTheme.tres")
		label.set_anchors_preset(Control.PRESET_TOP_LEFT)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.offset_left = 0
		label.offset_right = 0
		label.offset_bottom = 0
		label.offset_top = 0
		label.add_theme_font_size_override("font_size", 10)
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
