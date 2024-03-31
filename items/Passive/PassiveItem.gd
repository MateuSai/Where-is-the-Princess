class_name PassiveItem extends Item


func pick_up(player: Player) -> void:
	super(player)

	player.pick_up_passive_item(self)


## Fucking Godot and his bad adress errors. Because for some reason this crahses if I put it on a variable, override this function instead
func get_description() -> String:
	return "No description"


func get_unite_dictionary() -> Dictionary:
	return {}
