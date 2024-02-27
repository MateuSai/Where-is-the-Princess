class_name TemporalPassiveItem extends PassiveItem


## This function will be executed when the player picks up the passive item
func equip(_player: Player) -> void:
	pass


func unequip(_player: Player) -> void:
	pass


func get_max_amount() -> int:
	return -1


func can_pick_up(player: Player) -> bool:
	if get_max_amount() != -1:
		return SavedData.run_stats.get_amount_of_temporl_passive_items_of_type(self) < get_max_amount()
	else:
		return super(player)
