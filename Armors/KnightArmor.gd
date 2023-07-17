class_name KnightArmor extends Armor


func _init() -> void:
	tr("Knight")
	tr("Heavy armored, it allows you to block some attacks")
	initialize("Knight", "Heavy armored, it allows you to block some attacks", load("res://Art/player/armor_01.png"), 2, 0.5, 2)


func use_ability(player: Player) -> void:
	player.life_component.invincible = true
	ability_effect_ended.connect(func(): player.life_component.invincible = false)
	super(player)
	#await  player.get_tree().create_timer(2).timeout
	# player.invincible = false
