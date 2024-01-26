class_name ArmorItem extends Item

const SPRITE_SHEET: Texture = preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armors_icons.png")

var armor: Armor


@warning_ignore("shadowed_variable")
func initialize(armor: Armor) -> void:
	self.armor = armor

func pick_up(player: Player) -> void:
	assert(armor)
	player.set_armor(armor)


func get_icon() -> Texture2D:
	return armor.icon


func get_quality() -> Quality:
	return armor.get_quality()


func get_item_name() -> String:
	return armor.name


func get_item_description() -> String:
	return armor.description
