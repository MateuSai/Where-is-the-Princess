class_name TemporalPassiveItem extends PassiveItem

func get_max_amount() -> int:
	return - 1

func can_pick_up(player: Player) -> bool:
	if get_max_amount() != - 1:
		return SavedData.run_stats.get_amount_of_temporl_passive_items_of_type(self) < get_max_amount()
	else:
		return super(player)
