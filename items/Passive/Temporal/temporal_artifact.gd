class_name TemporalArtifact extends Artifact

func get_max_amount() -> int:
	return - 1

func can_pick_up(player: Player) -> bool:
	if get_max_amount() != - 1:
		Log.debug("Actual: " + str(SavedData.run_stats.get_amount_of_temporl_passive_items_of_type(self)) + "\tMax: " + str(get_max_amount()))
		return SavedData.run_stats.get_amount_of_temporl_passive_items_of_type(self) < get_max_amount()
	else:
		return super(player)

func get_coin_cost() -> int:
	return 10 + 10 * get_quality()
