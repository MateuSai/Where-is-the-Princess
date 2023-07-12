extends MarginContainer

@onready var player: Player = owner.get_node("Player")

@onready var armors_grid: GridContainer = get_node("HBoxContainer/Armors")

@onready var name_label: Label = get_node("HBoxContainer/ArmorDetails/NameLabel")
@onready var description_label: Label = get_node("HBoxContainer/ArmorDetails/DescriptionLabel")


func _ready() -> void:
	var armors: Array[Armor] = [NoArmor.new(), KnightArmor.new()]
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


class ArmorGridButton extends Button:
	var armor: Armor

	@warning_ignore("shadowed_variable")
	func _init(armor: Armor) -> void:
		self.armor = armor

		var atlas_tex: AtlasTexture = AtlasTexture.new()
		atlas_tex.atlas = armor.sprite_sheet
		atlas_tex.region = Rect2(0, 0, 16, 16)
		icon = atlas_tex
