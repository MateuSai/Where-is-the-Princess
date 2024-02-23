extends Armor

const POISON_CLOUD_SCENE: PackedScene = preload("res://effects/poison_cloud.tscn")


func _init() -> void:
	initialize(10, load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_warrior_icon.png") as Texture2D, 10)


func enable_ability_effect(player: Player) -> void:
	var amount: int = randi_range(10, 14)
	var angle_step: float = 2 * PI / amount
	var initial_angle: float = randf_range(0.0, angle_step)

	for i: int in amount:
		var poison_cloud: AcidPuddle = POISON_CLOUD_SCENE.instantiate()
		poison_cloud.position = player.global_position + Vector2.RIGHT.rotated(initial_angle + i * angle_step) * randf_range(8, 32)
		player.get_tree().current_scene.add_child(poison_cloud)


func disable_ability_effect(_player: Player) -> void:
	pass


func get_sprite_sheet() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_09.png")


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_09_icon.png") as Texture2D
