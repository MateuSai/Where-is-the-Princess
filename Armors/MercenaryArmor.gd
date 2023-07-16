extends Armor


func _init() -> void:
	tr("Mercenary")
	tr("Mercenary armor description")
	initialize("Mercenary", "", load("res://Art/player/armor_02.png"), 10, 15, 5)


func use_ability(player: Player) -> void:
	player.damage_multiplier += 1
	player.life_component.damage_taken_multiplier += 1
	ability_effect_ended.connect(func():
		player.damage_multiplier -= 1
		player.life_component.damage_taken_multiplier -= 1
	)
	super(player)
