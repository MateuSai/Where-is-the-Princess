extends MarginContainer

@onready var player: Player = owner.get_node("Player")

@onready var armors_grid: GridContainer = get_node("HBoxContainer/Armors")

@onready var name_label: Label = get_node("HBoxContainer/ArmorDetails/NameLabel")


func _ready() -> void:
	var armors: Array[Armor] = [NoArmor.new(), KnightArmor.new()]
	for armor in armors:
		var armor_grid_button: ArmorGridButton = ArmorGridButton.new(armor)
		armors_grid.add_child(armor_grid_button)

	_on_armor_selected(player.armor)


func _on_armor_selected(armor: Armor) -> void:
	name_label.text = armor.get_class()


class ArmorGridButton extends Button:
	var armor: Armor

	@warning_ignore("shadowed_variable")
	func _init(armor: Armor) -> void:
		self.armor = armor

		var atlas_tex: AtlasTexture = AtlasTexture.new()
		atlas_tex.atlas = armor.sprite_sheet
		atlas_tex.region = Rect2(0, 0, 16, 16)
		icon = atlas_tex
