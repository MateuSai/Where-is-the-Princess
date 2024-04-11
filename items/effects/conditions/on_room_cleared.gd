class_name OnRoomCleared extends ItemEffectsCondition
    
@warning_ignore("shadowed_variable")
func enable(player: Player) -> void:
    super(player)

    for room: DungeonRoom in (player.get_tree().current_scene as Game).rooms.rooms:
        room.cleared.connect(_on_room_cleared)

@warning_ignore("shadowed_variable")
func disable(player: Player) -> void:
    super(player)

    for room: DungeonRoom in (player.get_tree().current_scene as Game).rooms.rooms:
        room.cleared.disconnect(_on_room_cleared)

func _on_room_cleared() -> void:
    _enable_effects()