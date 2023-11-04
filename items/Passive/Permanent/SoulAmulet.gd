class_name SoulAmulet extends PermanentPassiveItem


func get_icon() -> Texture:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/soul_amulet.png")


func equip(player: Player) -> void:
	player.attract_souls_even_on_combat = true


func unequip(_player: Player) -> void:
	pass
