class_name Whetstone extends Item

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/whetstone.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Whetstone_UI_desc.png")

func can_pick_up(player: Player) -> bool:
	return player.weapons.current_weapon.get_index() > 0 and player.weapons.current_weapon.stats.condition < 100

func pick_up(player: Player) -> void:
	super(player)

	player.weapons.current_weapon.stats.set_condition(player.weapons.current_weapon.stats.condition + 50)
