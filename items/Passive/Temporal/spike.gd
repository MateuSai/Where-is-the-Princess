class_name Spike extends TemporalArtifact

var animation: Node2D = null

@export var hp: int = 3

const SPIKE_ON_PLAYER_ANIMATION_SCENE: PackedScene = preload ("res://items/Passive/Temporal/spike_on_player_animation.tscn")

func equip(player: Player) -> void:
	player.life_component.thorn_damage += 1
	player.life_component.thorn_damage_used.connect(_on_thorn_damage)

	animation = SPIKE_ON_PLAYER_ANIMATION_SCENE.instantiate()
	if SavedData.run_stats.get_amount_of_temporal_artifact_of_type(self) == 1:
		animation.scale.x = -1
	player.add_child(animation)

func unequip(player: Player) -> void:
	player.life_component.thorn_damage_used.disconnect(_on_thorn_damage)
	player.life_component.thorn_damage -= 1

	assert(is_instance_valid(animation))
	animation.queue_free()

func get_icon() -> Texture2D:
	return load("res://Art/items/Spike_icon.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/Spike_UI_desc.png")

func get_max_amount() -> int:
	return 2

func _on_thorn_damage() -> void:
	hp -= 1
	if hp <= 0:
		Globals.player.unequip_passive_item(self)
