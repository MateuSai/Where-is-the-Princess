class_name HeartStone extends PermanentPassiveItem

var player: Player = null


@warning_ignore("shadowed_variable")
func equip(player: Player) -> void:
	self.player = player

	for room: DungeonRoom in (player.get_tree().current_scene as Game).rooms.rooms:
		room.closed.connect(_on_room_closed)


func unequip(_player: Player) -> void:
	for room: DungeonRoom in (player.get_tree().current_scene as Game).rooms.rooms:
		room.closed.disconnect(_on_room_closed)


func _on_room_closed() -> void:
	player.life_component.hp += 1


func get_icon() -> Texture2D:
	return load("res://Art/items/Hearth_Stone.png")


func get_big_icon() -> Texture2D:
	return load("res://Art/items/Hearth_Stone_UI_desc.png")
