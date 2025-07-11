class_name GodlyWhetstone extends Item

func get_coin_cost() -> int:
	return 21

func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/whetstone_max.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Whetstone_max_UI_desc.png")

func can_pick_up(player: Player) -> bool:
	return player.weapons.current_weapon.get_index() > 0 and player.weapons.current_weapon.stats.condition < 100

func pick_up(player: Player) -> void:
	super(player)

	player.weapons.current_weapon.stats.set_condition(100)
