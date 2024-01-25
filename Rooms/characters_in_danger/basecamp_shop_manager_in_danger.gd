extends CharacterInDanger


#func _ready() -> void:
	#super()
#
	#jail_interact_area.player_interacted.connect(_on_jail_interacted)
#
	#room.last_enemy_died.connect(func(enemy: Enemy) -> void:
		#var key_scene: PackedScene = load("res://items/ShopManagerJailKey.tscn")
		#var key: JailKey = key_scene.instantiate()
		#key.position = enemy.global_position
		#get_tree().current_scene.call_deferred("add_child", key)
		#await get_tree().process_frame
		#key.go_to_player()
	#)


#func _on_player_interacted() -> void:
#	if room_cleared:
#		pass
#
#	super()


func _on_jail_interacted() -> void:
	if room_cleared:
		SavedData.data.items_shop_unlocked = true

	super()
