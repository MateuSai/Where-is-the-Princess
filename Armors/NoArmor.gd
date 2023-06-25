class_name NoArmor extends Armor


func _init() -> void:
	initialize(load("res://Art/player/no_armor.png"), 1.5)


func use_ability(player: Player) -> void:
	player.jump()
	super(player)
