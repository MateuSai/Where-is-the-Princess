class_name Oil extends TemporalPassiveItem


func _init() -> void:
	_initialize(load("res://Art/Furniture and room elements/wardrobe.png"))


func equip(player: Player) -> void:
	player.weapons.current_weapon.add_status_inflicter(StatusComponent.Status.FIRE)


func unequip(_player: Player) -> void:
	pass
