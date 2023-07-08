class_name KnightArmor extends Armor


func _init() -> void:
	initialize(tr("Knight"), load("res://Art/player/armor_01.png"), 0.5, 2)


func use_ability(player: Player) -> void:
	player.invincible = true
	ability_effect_ended.connect(func(): player.invincible = false)
	super(player)
	#await  player.get_tree().create_timer(2).timeout
	# player.invincible = false
