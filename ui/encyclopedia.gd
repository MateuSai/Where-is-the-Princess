class_name Encyclopedia extends MarginContainer

enum {
	WEAPONS,
	ARMORS,
	ITEMS,
	ENEMIES,
}

@onready var category_buttons: VBoxContainer = $HBoxContainer/CategoryButtons
@onready var flow_container: HFlowContainer = $HBoxContainer/ScrollContainer/HFlowContainer
@onready var details_vbox: VBoxContainer = $HBoxContainer/DetailsScrollContainer/VBoxContainer


func _ready() -> void:
	for button: Button in category_buttons.get_children():
		assert(button is Button)
		button.pressed.connect(func() -> void: _set_category(button.get_index()))

	_set_category(WEAPONS)


func _set_category(new_category: int) -> void:
	for i: int in range(flow_container.get_child_count() - 1, -1, -1):
		flow_container.get_child(i).free()

	match new_category:
		WEAPONS:
			var discovered_weapon_paths: PackedStringArray = SavedData.get_discovered_weapon_paths()
			for weapon_path: String in SavedData.get_all_weapon_paths():
				var weapon_data: WeaponData = Weapon.get_data(Weapon.get_id_from_path(weapon_path))
				var icon: TextureRect = TextureRect.new()
				icon.texture = weapon_data.icon
				if not discovered_weapon_paths.has(weapon_path):
					icon.modulate = Color.BLACK
				flow_container.add_child(icon)
		ARMORS:
			var discovered_armor_paths: PackedStringArray = SavedData.get_discovered_armors_paths()
			for armor_path: String in SavedData.get_all_armor_paths():
				var armor: Armor = load(armor_path).new()
				var button: Button = Button.new()
				button.icon = armor.get_icon()
				if not discovered_armor_paths.has(armor_path):
					button.modulate = Color.BLACK
					button.disabled = true
				else:
					button.pressed.connect(func() -> void:
						for i: int in range(details_vbox.get_child_count() - 1, -1, -1):
							details_vbox.get_child(i).free()

						var armor_texture: TextureRect = TextureRect.new()
						armor_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH
						armor_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
						armor_texture.custom_minimum_size.y = 64
						var atlas: AtlasTexture = AtlasTexture.new()
						atlas.atlas = armor.get_sprite_sheet()
						atlas.region = Rect2(0, 0, 16, 16)
						armor_texture.texture = atlas
						details_vbox.add_child(armor_texture)

						var name_label: Label = Label.new()
						name_label.custom_minimum_size.x = details_vbox.size.x - 16
						name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
						name_label.text = armor.get_armor_name()
						details_vbox.add_child(name_label)

						var description_label: Label = Label.new()
						description_label.theme = load("res://SmallFontTheme.tres")
						description_label.custom_minimum_size.x = details_vbox.size.x - 16
						description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
						description_label.text = armor.get_description()
						details_vbox.add_child(description_label)
					)
				flow_container.add_child(button)
		ITEMS:
			var discovered_item_paths: PackedStringArray = SavedData.get_discovered_all_items_paths()
			for item_path: String in SavedData.get_all_items_paths():
				var item: Item = load(item_path).new()
				var icon: TextureRect = TextureRect.new()
				icon.texture = item.get_icon()
				if not discovered_item_paths.has(item_path):
					icon.modulate = Color.BLACK
				flow_container.add_child(icon)
		ENEMIES:
			var enemies_statistics: Dictionary = SavedData.statistics.get_enemies_statistics()
			for enemy_id: String in enemies_statistics.keys():
				var enemy_statistics: EnemyStatistics = enemies_statistics[enemy_id]
				var icon: TextureRect = TextureRect.new()
				icon.texture = load("res://Art/Dust.png")
				flow_container.add_child(icon)
