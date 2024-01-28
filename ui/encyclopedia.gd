class_name Encyclopedia extends MarginContainer

enum {
	WEAPONS,
	ARMORS,
	ENEMIES,
}

@onready var category_buttons: VBoxContainer = $HBoxContainer/CategoryButtons
@onready var flow_container: HFlowContainer = $HBoxContainer/ScrollContainer/HFlowContainer


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
			for weapon_path: String in Data.ALL_VANILLA_WEAPONS:
				var weapon_data: WeaponData = Weapon.get_data(Weapon.get_id_from_path(weapon_path))
				var icon: TextureRect = TextureRect.new()
				icon.texture = weapon_data.icon
				flow_container.add_child(icon)
		ARMORS:
			var available_armor_paths: PackedStringArray = SavedData.get_available_armor_paths()
			for armor_path: String in SavedData.get_all_armor_paths():
				var armor: Armor = load(armor_path).new()
				var icon: TextureRect = TextureRect.new()
				icon.texture = armor.get_icon()
				if not available_armor_paths.has(armor_path):
					icon.modulate = Color.BLACK
				flow_container.add_child(icon)
		ENEMIES:
			var enemies_data: Dictionary = SavedData.data.get_enemies_data()
			for enemy_id: String in enemies_data.keys():
				var enemy_data: EnemyData = enemies_data[enemy_id]
				var icon: TextureRect = TextureRect.new()
				icon.texture = load("res://Art/Dust.png")
				flow_container.add_child(icon)
