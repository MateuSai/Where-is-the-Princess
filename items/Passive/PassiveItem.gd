class_name PassiveItem extends Item

var effects: Array[ItemEffect] = []

func pick_up(player: Player) -> void:
	super(player)

	player.pick_up_passive_item(self)

## This function will be executed when the player picks up the passive item
func equip(player: Player) -> void:
	for effect: ItemEffect in effects:
		effect.enable(player)

func unequip(player: Player) -> void:
	for effect: ItemEffect in effects:
		effect.disable(player)

## Fucking Godot and his bad adress errors. Because for some reason this crahses if I put it on a variable, override this function instead
func get_description() -> String:
	return "No description"

func get_unite_dictionary() -> Dictionary:
	return {}
