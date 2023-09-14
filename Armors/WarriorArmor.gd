extends Armor

const ABILITY_SCENE: PackedScene = preload("res://Armors/WarriorArmorAbility.tscn")


func _init() -> void:
	initialize("WARRIOR", "WARRIOR_ARMOR_DESCRIPTION", load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_03.png"), 10, load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_warrior_icon.png"), 1)


func enable_ability_effect(player: Player) -> void:
	var ability: GPUParticles2D = ABILITY_SCENE.instantiate()
	ability.position = player.position
	player.get_tree().current_scene.add_child(ability)


func disable_ability_effect(_player: Player) -> void:
	pass
