class_name PlayerUpgrade extends Item

var amount: int = 1


func can_pick_up(_player: Player) -> bool:
	var can_pick: bool = SavedData.data.can_pick_up_player_upgrade(get_item_name())

	if not can_pick:
		push_error("Something is wrong here: You should not see this player upgrade item anymore if it already has the max amount")

	return can_pick


func pick_up(player: Player) -> void:
	var found: bool = false

	for player_upgrade: PlayerUpgrade in SavedData.data.player_upgrades:
		if player_upgrade.get_item_name() == get_item_name():
			player_upgrade.amount += 1
			found = true
			break

	if not found:
		SavedData.data.player_upgrades.push_back(self)

	SavedData.data.save()

	equip(player)

	player.player_upgrade_item_picked_up.emit(self)


func equip(_player: Player) -> void:
	pass


func get_max_amount() -> int:
	push_warning("Default max amount is 3, overwrite this function to change it")
	return 3


func to_dic() -> Dictionary:
	return {
		path = (get_script() as Script).resource_path,
		amount = amount,
	}


static func from_dic(dic: Dictionary) -> PlayerUpgrade:
	if not dic.has("path") or not dic.has("amount"):
		push_error("Error creating PlayerUpgrade: dic must have keys path and amount")
		return null

	assert(dic.path is String)

	@warning_ignore("unsafe_call_argument")
	var player_upgrade: PlayerUpgrade = (load(dic.path) as GDScript).new()
	player_upgrade.amount = dic.amount
	return player_upgrade
