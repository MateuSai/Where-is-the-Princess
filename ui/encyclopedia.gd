class_name Encyclopedia extends MarginContainer

enum {
	WEAPONS,
	ARMORS,
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
			for armor_path: String in Data.ALL_VANILLA_ARMORS:
				var armor: Armor = load(armor_path).new()
				var icon: TextureRect = TextureRect.new()
				icon.texture = armor.get_icon()
				flow_container.add_child(icon)
