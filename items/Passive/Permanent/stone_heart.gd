class_name StoneHeart extends PermanentPassiveItem


var player: Player = null


@warning_ignore("shadowed_variable")
func equip(player: Player) -> void:
	self.player = player

	for room: DungeonRoom in (player.get_tree().current_scene as Game).rooms.rooms:
		room.cleared.connect(_on_room_cleared)


func unequip(_player: Player) -> void:
	for room: DungeonRoom in (player.get_tree().current_scene as Game).rooms.rooms:
		room.cleared.disconnect(_on_room_cleared)


func _on_room_cleared() -> void:
	player.life_component.hp += 1


func get_icon() -> Texture2D:
	return load("res://Art/items/Stone_Hearth.png")
