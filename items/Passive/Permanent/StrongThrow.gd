class_name StrongThrow extends PermanentPassiveItem


#func _init() -> void:
#	_initialize(load("res://Art/slime shadow.png"))


func equip(player: Player) -> void:
	player.throw_piercing += 1


func unequip(player: Player) -> void:
	player.throw_piercing -= 1


func get_icon() -> Texture:
	return load("res://Art/items/Bolt_icon.png")
