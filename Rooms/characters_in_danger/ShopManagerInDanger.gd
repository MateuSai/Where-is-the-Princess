extends CharacterInDanger


func _on_player_interacted() -> void:
	if room_cleared:
		if not character_is_free:
			SavedData.data.shop_unlocked = true

	super()
