class_name HeartStone extends PermanentPassiveItem

var player: Player = null


@warning_ignore("shadowed_variable")
func equip(player: Player) -> void:
	self.player = player

	for room: DungeonRoom in (player.get_tree().current_scene as Game).rooms.rooms:
		room.closed.connect(_on_room_closed)


func unequip(_player: Player) -> void:
	pass


func _on_room_closed() -> void:
	player.life_component.hp += 1


func get_icon() -> Texture2D:
	return load("res://Art/items/Hearth_Stone.png")
