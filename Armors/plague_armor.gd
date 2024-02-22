extends Armor

const ABILITY_SCENE: PackedScene = preload("res://Armors/WarriorArmorAbility.tscn")


func _init() -> void:
	initialize(10, load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_warrior_icon.png") as Texture2D, 10)


func enable_ability_effect(player: Player) -> void:
	var ability: GPUParticles2D = ABILITY_SCENE.instantiate()
	ability.position = player.position
	player.get_tree().current_scene.add_child(ability)


func disable_ability_effect(_player: Player) -> void:
	pass


func get_sprite_sheet() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_09.png")


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_09_icon.png") as Texture2D
