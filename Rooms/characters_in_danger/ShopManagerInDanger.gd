extends CharacterInDanger

@onready var static_body: StaticBody2D = $StaticBody2D
@onready var jail_interact_area: InteractArea = $StaticBody2D/InteractArea


func _ready() -> void:
	super()

	jail_interact_area.player_interacted.connect(_on_jail_interacted)

	room.last_enemy_died.connect(func(enemy: Enemy):
		var key: Area2D = load("res://items/ShopManagerJailKey.tscn").instantiate()
		key.position = enemy.global_position
		get_tree().current_scene.call_deferred("add_child", key)
		await get_tree().process_frame
		key.go_to_player()
	)


#func _on_player_interacted() -> void:
#	if room_cleared:
#		pass
#
#	super()


func _on_jail_interacted() -> void:
	if room_cleared:
		SavedData.data.shop_unlocked = true
		static_body.queue_free()
		$JailBack.queue_free()
		$JailFront.queue_free()
		SavedData.add_ignored_room(room.scene_file_path)
		#character.interact_area.player_interacted.connect(_on_player_interacted)
		character.dialogue_texts = dialogues_after_saving
		character.interact_area.player_interacted.connect(character._on_player_interacted)
