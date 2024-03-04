class_name Fairy extends TemporalPassiveItem

var default_set_hp_function: Callable


func get_icon() -> Texture2D:
	return load("res://Art/items/orbital_sword_icon.png")


func equip(player: Player) -> void:
	default_set_hp_function = player.life_component._set_hp
	player.life_component._set_hp = func(new_hp: int) -> void:
		if new_hp <= 0:
			player.unequip_passive_item(self)
			player.life_component.hp = 4
			return

		default_set_hp_function.call(new_hp)


func unequip(player: Player) -> void:
	player.life_component._set_hp = default_set_hp_function


func get_quality() -> Quality:
	return Quality.CHINGON


func get_max_amount() -> int:
	return 1
