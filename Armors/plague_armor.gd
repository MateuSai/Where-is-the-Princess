extends Armor

const POISON_CLOUD_SCENE: PackedScene = preload("res://effects/poison_cloud.tscn")


func _init() -> void:
	initialize(4, load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Armor_plague_icon.png") as Texture2D, 10)


func equip(player: Player) -> void:
	player.acid_progress_per_second *= 0.6


func unequip(player: Player) -> void:
	player.acid_progress_per_second /= 0.6


func enable_ability_effect(player: Player) -> void:
	for i: int in 4:
		var amount: int = randi_range(7, 13)
		var angle_step: float = 2 * PI / amount
		var initial_angle: float = randf_range(0.0, angle_step)

		for j: int in amount:
			var poison_cloud: AcidPuddle = POISON_CLOUD_SCENE.instantiate()
			poison_cloud.position = player.global_position + Vector2.RIGHT.rotated(initial_angle + j * angle_step) * randf_range(0, 30)
			player.get_tree().current_scene.add_child(poison_cloud)

		await player.get_tree().create_timer(0.2).timeout


func disable_ability_effect(_player: Player) -> void:
	pass


func get_sprite_sheet() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_09.png")


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/armor_09_icon.png") as Texture2D
