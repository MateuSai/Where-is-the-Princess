class_name Fairy extends TemporalArtifact

var default_set_hp_function: Callable

func equip(player: Player) -> void:
	super(player)

	default_set_hp_function = player.life_component._set_hp
	player.life_component._set_hp = func(new_hp: int) -> void:
		if new_hp <= 0:
			player.unequip_passive_item(self)
			player.life_component.hp = 4
			return

		default_set_hp_function.call(new_hp)

func unequip(player: Player) -> void:
	super(player)

	player.life_component._set_hp = default_set_hp_function

func get_quality() -> Quality:
	return Quality.CHINGON

func get_max_amount() -> int:
	return 1

func get_icon() -> Texture2D:
	return load("res://Art/items/fairy_animation.tres")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/fairy_UI_desc.png")
