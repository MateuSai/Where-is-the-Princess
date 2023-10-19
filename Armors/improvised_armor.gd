extends Armor


func _init() -> void:
	initialize("IMPROVISED_ARMOR", "IMPROVISED_ARMOR_DESCRIPTION", load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_08.png"), 2)


func equip(player: Player) -> void:
	Globals.player.weapon_degradation_reduction += 0.2


func unequip(_player: Player) -> void:
	Globals.player.weapon_degradation_reduction -= 0.2
