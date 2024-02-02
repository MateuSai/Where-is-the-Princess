class_name Underpants extends Armor


func _init() -> void:
	initialize(0, load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_naked_icon.png") as Texture2D, 1.5)


func equip(player: Player) -> void:
	player.data.max_speed += 10


func unequip(player: Player) -> void:
	player.data.max_speed -= 10


func enable_ability_effect(_player: Player) -> void:
	pass
	#player.jump()


func get_sprite_sheet() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/no_armor.png")
