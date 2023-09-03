extends CharacterInDanger


func _on_player_interacted() -> void:
	if room_cleared:
		SavedData.data.shop_unlocked = true

	super()
