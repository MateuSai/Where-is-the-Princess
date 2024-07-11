class_name OnRoomClosed extends ItemEffectsCondition

@warning_ignore("shadowed_variable")
func enable(player: Player) -> void:
	super(player)

	for room: DungeonRoom in (player.get_tree().current_scene as Game).rooms.rooms:
		room.closed.connect(_on_room_closed)

@warning_ignore("shadowed_variable")
func disable(player: Player) -> void:
	super(player)

	for room: DungeonRoom in (player.get_tree().current_scene as Game).rooms.rooms:
		room.closed.disconnect(_on_room_closed)

func _on_room_closed() -> void:
	_enable_effects()

func get_description() -> String:
	return "%s\n%s" % [tr("ON_ROOM_CLOSED"), super()]
