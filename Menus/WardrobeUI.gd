extends MarginContainer

const ARMORS_FOLDER_PATH: String = "res://Armors/ArmorsThatWillBeLoaded/"

@onready var player: Player = owner.get_node("Player")

@onready var armors_grid: GridContainer = get_node("HBoxContainer/Armors")

@onready var name_label: Label = get_node("HBoxContainer/ArmorDetails/NameLabel")
@onready var description_label: Label = get_node("HBoxContainer/ArmorDetails/DescriptionLabel")


func _ready() -> void:
	var armor_names: PackedStringArray = _get_armors()
	var armors: Array[Armor] = []
	for armor_name in armor_names:
		armors.push_back(load(ARMORS_FOLDER_PATH + armor_name).new())
	# Ponemos NoArmor al inicio
	armors.sort_custom(func(armor1: Armor, _armor2: Armor) -> bool:
		if armor1 is NoArmor:
			return true
		return false
	)
	for armor in armors:
		var armor_grid_button: ArmorGridButton = ArmorGridButton.new(armor)
		armor_grid_button.focus_entered.connect(func(): _on_armor_selected(armor_grid_button.armor))
		armors_grid.add_child(armor_grid_button)
#		if player.armor.name == armor.name:
#			armor_grid_button.grab_focus()

	_on_armor_selected(player.armor)

	draw.connect(func():
		#print(player.armor.name)
		for button in armors_grid.get_children():
			print(button.armor.name + "  " + player.armor.name)
			if player.armor.name == button.armor.name:
				button.grab_focus()
	)


func _on_armor_selected(armor: Armor) -> void:
	name_label.text = armor.name
	description_label.text = armor.description
	player.set_armor(armor)


func _get_armors() -> PackedStringArray:
	var armors_dir: DirAccess = DirAccess.open(ARMORS_FOLDER_PATH)
	if armors_dir == null:
		printerr("Error opening " + ARMORS_FOLDER_PATH + "!")
		return []

	var armor_names: PackedStringArray = armors_dir.get_files()
#	for i in room_names.size():
#		room_names[i] = room_names[i].trim_suffix(".remap")
	return armor_names


class ArmorGridButton extends Button:
	var armor: Armor

	@warning_ignore("shadowed_variable")
	func _init(armor: Armor) -> void:
		self.armor = armor

		var atlas_tex: AtlasTexture = AtlasTexture.new()
		atlas_tex.atlas = armor.sprite_sheet
		atlas_tex.region = Rect2(0, 0, 16, 16)
		icon = atlas_tex
