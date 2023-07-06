class_name NoArmor extends Armor


func _init() -> void:
	initialize(load("res://Art/player/no_armor.png"), 1.5)


func equip(player: Player) -> void:
	player.max_speed += 10


func unequip(player: Player) -> void:
	player.max_speed -= 10


func use_ability(player: Player) -> void:
	player.jump()
	super(player)
