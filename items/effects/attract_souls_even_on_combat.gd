class_name AttractSoulsEvenOnCombat extends ItemEffect

func enable(player: Player) -> void:
	player.attract_souls_even_on_combat += 1

func disable(player: Player) -> void:
	player.attract_souls_even_on_combat -= 1

func get_description() -> String:
	return _get_color_tag(GREEN) % (tr("ATTRACT_SOULS_EVEN_ON_COMBAT"))
