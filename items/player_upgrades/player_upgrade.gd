class_name PlayerUpgrade extends Item

var amount: int = 1


func pick_up(player: Player) -> void:
	var found: bool = false

	for player_upgrade: PlayerUpgrade in SavedData.data.player_upgrades:
		if (player_upgrade.get_script() as Script).get_class() == (self.get_script() as Script).get_class():
			player_upgrade.amount += 1
			found = true
			break

	if not found:
		SavedData.data.player_upgrades.push_back(self)

	SavedData.save_data()

	equip(player)


func equip(_player: Player) -> void:
	pass


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
