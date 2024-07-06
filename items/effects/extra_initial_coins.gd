class_name ExtraInitialCoins extends ItemEffect

var _amount: int

func _init(amount: int) -> void:
	self._amount = amount

func enable(_player: Player) -> void:
	if SavedData.get_biome_conf().name == "FOREST" and SavedData.run_stats.level == 1:
		SavedData.run_stats.coins += _amount

func disable(_player: Player) -> void:
	pass

func get_description() -> String:
	return _get_color_tag(GREEN if _amount > 0 else RED) % (tr("EXTRA_INITIAL_COINS") % _amount)
