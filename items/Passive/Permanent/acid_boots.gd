class_name AcidBoots extends PermanentPassiveItem

var player: Player

const ACID_PUDDLE_SCENE: PackedScene = preload("res://Characters/Enemies/MediumSlime/acid_puddle.tscn")


@warning_ignore("shadowed_variable")
func equip(player: Player) -> void:
	self.player = player
	player.dashed.connect(_on_dashed)
	player.acid_progress_per_second -= 0.2


@warning_ignore("shadowed_variable")
func unequip(player: Player) -> void:
	player.dashed.disconnect(_on_dashed)
	player.acid_progress_per_second += 0.2


func _on_dashed(dash_time: float) -> void:
	var time: float = 0.0
	var spawn_acid_interval: float = 0.03

	while time <= (dash_time * 2.5):
		var acid_puddle: Area2D = ACID_PUDDLE_SCENE.instantiate()
		acid_puddle.position = player.global_position
		player.get_tree().current_scene.add_child(acid_puddle)

		time += spawn_acid_interval
		await player.get_tree().create_timer(spawn_acid_interval).timeout


func get_icon() -> Texture2D:
	return load("res://Art/items/boots_acid_icon.png")
