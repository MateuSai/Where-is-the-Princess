extends MarginContainer

#@onready var player: Player = owner.get_node("Player")

@onready var armors_grid: GridContainer = get_node("HBoxContainer/Armors")

@onready var name_label: Label = $HBoxContainer/ScrollContainer/ArmorDetails/NameLabel
@onready var description_label: Label = $HBoxContainer/ScrollContainer/ArmorDetails/DescriptionLabel


func _ready() -> void:
	var armors: Array[Armor] = [Underpants.new()]

	for armor_path: String in SavedData.get_discovered_armors_paths():
		armors.push_back(load(armor_path).new())

	for armor: Armor in armors:
		var armor_grid_button: ArmorGridButton = ArmorGridButton.new(armor)
		armor_grid_button.focus_entered.connect(func() -> void: _on_armor_selected(armor_grid_button.armor))
		armors_grid.add_child(armor_grid_button)
#		if player.armor.name == armor.name:
#			armor_grid_button.grab_focus()

	draw.connect(func() -> void:
		name_label.text = Globals.player.armor.name
		description_label.text = Globals.player.armor.description
		#print(player.armor.name)
		for button: ArmorGridButton in armors_grid.get_children():
			#print(button.armor.name + "  " + player.armor.name)
			if Globals.player.armor.name == button.armor.name:
				button.grab_focus()
	)


func _on_armor_selected(armor: Armor) -> void:
	name_label.text = armor.name
	description_label.text = armor.description
	Globals.player.set_armor(armor)
	SavedData.data.equipped_armor = (armor.get_script() as Script).get_path()


class ArmorGridButton extends Button:
	var armor: Armor

	@warning_ignore("shadowed_variable")
	func _init(armor: Armor) -> void:
		self.armor = armor

		var atlas_tex: AtlasTexture = AtlasTexture.new()
		atlas_tex.atlas = armor.sprite_sheet
		atlas_tex.region = Rect2(0, 0, 16, 16)
		icon = atlas_tex
