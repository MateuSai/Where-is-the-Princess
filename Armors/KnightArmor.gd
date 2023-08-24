class_name KnightArmor extends Armor


func _init() -> void:
	tr("Knight")
	tr("Heavy armored, it allows you to block some attacks")
	initialize("Knight", "Heavy armored, it allows you to block some attacks", load("res://Art/player/armor_01.png"), 2, load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_naked_icon.png"), 0.5, 2)


func enable_ability_effect(player: Player) -> void:
	player.life_component.invincible = true


func disable_ability_effect(player: Player) -> void:
	player.life_component.invincible = false
