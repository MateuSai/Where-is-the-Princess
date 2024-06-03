class_name Grandpa extends NPC

@onready var room: DungeonRoom = owner

func _ready() -> void:
	interact_area.queue_free()

	hide()

	room.closed.connect(func() -> void:
		var spawn_explosion: AnimatedSprite2D=DungeonRoom.SPAWN_EXPLOSION_SCENE.instantiate()
		spawn_explosion.position=position
		room.call_deferred("add_child", spawn_explosion)

		show()

		if room is TutorialForestChestRoom:
			display_tip()
	)
	room.cleared.connect(func() -> void:
		queue_free()

		var spawn_explosion: AnimatedSprite2D=DungeonRoom.SPAWN_EXPLOSION_SCENE.instantiate()
		spawn_explosion.position=position
		room.call_deferred("add_child", spawn_explosion)
	)

func display_tip() -> void:
	dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
	add_child(dialogue_box)

	var key_open_tag: String = "[key]"
	var key_close_tag: String = "[/key]"

	var translated: String = tr("GRANDPA_CHEST_ROOM_TUTORIAL")

	var key_open_pos: int = translated.find(key_open_tag)
	var key_close_pos: int = translated.find(key_close_tag)

	var before_key_tag_portion: String = translated.substr(0, key_open_pos)
	var after_key_tag_portion: String = translated.substr(key_close_pos + key_close_tag.length(), -1)
	var action_name: String = translated.substr(key_open_pos + key_open_tag.length(), key_close_pos - key_open_pos - key_open_tag.length())

	Log.debug(before_key_tag_portion)
	Log.debug(after_key_tag_portion)
	Log.debug(action_name)

	var key_id: String
	if Globals.mode == Globals.Mode.MOUSE:
		key_id = InputMap.action_get_events(action_name)[0].as_text()
	else:
		key_id = Globals.get_joypad_event_image_id(InputMap.action_get_events(action_name)[1])

	dialogue_box.label.text += before_key_tag_portion
	var atlas_texture: AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = load("res://Art/kenney_input-prompts-pixel-16/Tilemap/tilemap_packed.png")
	atlas_texture.region = KeyIcon.get_key_region(key_id)
	Cache.get_key_image(key_id)
	#dialogue_box.label.text += "[img]" + Cache.get_key_image_path(key_id) + "[/img]"
	dialogue_box.label.add_image(Cache.get_key_image(key_id))
	dialogue_box.label.text += after_key_tag_portion

	Log.debug(dialogue_box.label.text)

	dialogue_box.start_displaying()

	#return before_key_tag_portion + KeyIcon.get_key_region(ui_action) + after_key_tag_portion