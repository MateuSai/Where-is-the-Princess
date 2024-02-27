class_name Spike extends PermanentPassiveItem

var animation: Node2D = null

const SPIKE_ON_PLAYER_ANIMATION_SCENE: PackedScene = preload("res://items/Passive/Permanent/spike_on_player_animation.tscn")


func equip(player: Player) -> void:
	player.life_component.thorn_damage += 1

	animation = SPIKE_ON_PLAYER_ANIMATION_SCENE.instantiate()
	player.add_child(animation)


func unequip(player: Player) -> void:
	player.life_component.thorn_damage -= 1

	assert(is_instance_valid(animation))
	animation.queue_free()


func get_icon() -> Texture2D:
	return load("res://Art/items/Spike_icon.png")
