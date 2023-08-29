class_name NoArmor extends Armor


func _init() -> void:
	initialize("UNDERPANTS", "UNDERPANTS_DESC", load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/no_armor.png"), 0, load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_naked_icon.png"), 1.5)


func equip(player: Player) -> void:
	player.max_speed += 10


func unequip(player: Player) -> void:
	player.max_speed -= 10


func enable_ability_effect(player: Player) -> void:
	player.jump()
