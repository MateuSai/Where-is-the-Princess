class_name PassiveItem extends Item


var description: String = "No description"


func pick_up(player: Player) -> void:
	player.pick_up_passive_item(self)
