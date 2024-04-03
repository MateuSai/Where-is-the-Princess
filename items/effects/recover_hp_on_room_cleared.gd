class_name RecoverHpOnRoomCleared extends ItemEffect

var player: Player

var hp_amount: int

@warning_ignore("shadowed_variable")
func _init(hp_amount: int) -> void:
	self.hp_amount = hp_amount
	
@warning_ignore("shadowed_variable")
func enable(player: Player) -> void:
	self.player = player

	for room: DungeonRoom in (player.get_tree().current_scene as Game).rooms.rooms:
		room.cleared.connect(_on_room_cleared)

@warning_ignore("shadowed_variable")
func disable(player: Player) -> void:
	for room: DungeonRoom in (player.get_tree().current_scene as Game).rooms.rooms:
		room.cleared.disconnect(_on_room_cleared)

func _on_room_cleared() -> void:
	player.life_component.hp += hp_amount
