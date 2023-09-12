extends Armor


func _init() -> void:
	initialize("NECROMANCER", "NECROMANCER_ARMOR_DESCRIPTION", load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_04.png"), 10, load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_necromancer_icon.png"), 15, 5)


func enable_ability_effect(player: Player) -> void:
	pass


func disable_ability_effect(player: Player) -> void:
	pass
