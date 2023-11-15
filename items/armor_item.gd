class_name ArmorItem extends Item

const SPRITE_SHEET: Texture = preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armors_icons.png")

var armor_path: String
var armor: Armor


@warning_ignore("shadowed_variable")
func initialize(armor_path: String) -> void:
	self.armor_path = armor_path
	self.armor = load(armor_path).new()


func pick_up(player: Player) -> void:
	assert(not armor_path.is_empty())
	player.set_armor(load(armor_path).new())


func get_icon() -> Texture:
	return armor.icon


func get_item_name() -> String:
	return armor_path.get_basename().get_file().to_snake_case().to_upper()


func get_item_description() -> String:
	return armor_path.get_basename().get_file().to_snake_case().to_upper() + "_DESCRIPTION"
