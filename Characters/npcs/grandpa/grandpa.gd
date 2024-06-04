class_name Grandpa extends NPC

@onready var room: DungeonRoom = owner

func _ready() -> void:
	interact_area.queue_free()

	hide()

	room.closed.connect(func() -> void:
		Log.debug("Room with grandpa closed")

		_spawn_explosion()

		show()

		if room is TutorialForestChestRoom:
			display_tip("GRANDPA_CHEST_ROOM_TUTORIAL", DIALOGUE_TOP_LEFT_POSITION_OFFSET, true)
		elif room is TutorialForestAttackPracticeRoom:
			display_tip("GRANDPA_ATTACK_TUTORIAL", DIALOGUE_BOTTOM_LEFT_POSITION_OFFSET)
			Globals.character_received_damage.connect(func(_character: Character, _damage_dealer: Node) -> void:
				display_tip("GRANDPA_WEAPON_ABILITY_TUTORIAL", DIALOGUE_BOTTOM_LEFT_POSITION_OFFSET)
			, CONNECT_ONE_SHOT)
		elif room is TutorialForestThrowPracticeRoom:
			display_tip("GRANDPA_THROW_TUTORIAL", DIALOGUE_TOP_LEFT_POSITION_OFFSET, true)
		elif room is TutorialForestJumpTutorial:
			display_tip("GRANDPA_JUMP_TUTORIAL")
			Globals.player.dashed.connect(func(_dash_time: float) -> void:
				_spawn_explosion()
				position=Vector2(51, 7)
				_spawn_explosion()
				display_tip("GRANDPA_EQUIP_ARMOR_TUTORIAL")
			, CONNECT_ONE_SHOT)
		elif room is TutorialForestArmorTutorialRoom:
			display_tip("GRANDPA_DASH_TUTORIAL")
			room.get_node("SecondPartArea").body_entered.connect(func(_body: Node2D) -> void:
				_spawn_explosion()
				position=Vector2(63, 42)
				_spawn_explosion()
				display_tip("GRANDPA_ARMOR_ABILITY_TUTORIAL", DIALOGUE_TOP_RIGHT_POSITION_OFFSET, true)
			)
	, CONNECT_ONE_SHOT)
	room.cleared.connect(func() -> void:
		Log.debug("Removing grandpa...")

		queue_free()

		_spawn_explosion()
	, CONNECT_ONE_SHOT)

func display_tip(dialogue_id: String, offset: Vector2=Vector2.ZERO, expand_up: bool=false) -> void:
	if dialogue_box:
		dialogue_box.queue_free()
		dialogue_box = null

	dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
	dialogue_box.position += offset
	dialogue_box.expand_up = expand_up
	add_child(dialogue_box)

	var key_open_tag: String = "[key]"
	var key_close_tag: String = "[/key]"

	var translated: String = tr(dialogue_id)

	var key_open_pos: int = translated.find(key_open_tag)
	var key_close_pos: int = translated.find(key_close_tag)

	var before_key_tag_portion: String = translated.substr(0, key_open_pos)
	var after_key_tag_portion: String = translated.substr(key_close_pos + key_close_tag.length(), -1)
	var action_name: String = translated.substr(key_open_pos + key_open_tag.length(), key_close_pos - key_open_pos - key_open_tag.length())

	#Log.debug(before_key_tag_portion)
	#Log.debug(after_key_tag_portion)
	#Log.debug(action_name)

	var key_id: String
	if Globals.mode == Globals.Mode.MOUSE:
		key_id = InputMap.action_get_events(action_name)[0].as_text()
	else:
		key_id = Globals.get_joypad_event_image_id(InputMap.action_get_events(action_name)[1])

	dialogue_box.label.text = before_key_tag_portion
	#var atlas_texture: AtlasTexture = AtlasTexture.new()
	#atlas_texture.atlas = load("res://Art/kenney_input-prompts-pixel-16/Tilemap/tilemap_packed.png")
	#atlas_texture.region = KeyIcon.get_key_region(key_id)
	#Cache.get_key_image(key_id)
	dialogue_box.label.text += "[img]" + KeyIcon.TILE_ICONS_FOLDER.path_join(key_id.to_lower().replace(" ", "_") + ".png") + "[/img]"
	#dialogue_box.label.add_image(Cache.get_key_image(key_id))
	dialogue_box.label.text += after_key_tag_portion

	Log.debug(dialogue_box.label.text)

	dialogue_box.start_displaying()

	#return before_key_tag_portion + KeyIcon.get_key_region(ui_action) + after_key_tag_portion

func _spawn_explosion() -> void:
	var spawn_explosion: AnimatedSprite2D = DungeonRoom.SPAWN_EXPLOSION_SCENE.instantiate()
	spawn_explosion.position = position
	room.call_deferred("add_child", spawn_explosion)
