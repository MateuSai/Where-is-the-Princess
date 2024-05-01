class_name CharacterInDanger extends Node2D

var dialogues_asking_for_help: PackedStringArray = []
var dialogues_after_saving: PackedStringArray = []

var room_cleared: bool = false
var say_something_timer: Timer

@onready var room: DungeonRoom = owner

@onready var character: NPC = $Character
@onready var static_body: StaticBody2D = $StaticBody2D
@onready var jail_interact_area: InteractArea = $StaticBody2D/InteractArea

func _ready() -> void:
	var upper_case_id: String = character.id.to_upper()
	Log.debug(upper_case_id)
	var i: int = 1
	while true:
		var dialogue_id: String = "%s_ASKING_FOR_HELP_%d" % [upper_case_id, i]
		if tr(dialogue_id) != dialogue_id: # Translation available
			dialogues_asking_for_help.push_back(dialogue_id)
		else:
			break
		i += 1
	Log.debug(character.id + " dialogues asking for help: " + str(dialogues_asking_for_help))
	i = 1
	while true:
		var dialogue_id: String = "%s_AFTER_SAVING_%d" % [upper_case_id, i]
		if tr(dialogue_id) != dialogue_id: # Translation available
			dialogues_after_saving.push_back(dialogue_id)
		else:
			break
		i += 1
	Log.dbg(character.id + " dialogues after saving: " + str(dialogues_after_saving))

	character.dialogues_in_order = true

	character.used_all_dialogues.connect(func() -> void:
		if is_instance_valid(say_something_timer):
			say_something_timer.queue_free()
		
		if room_cleared:
			character.interact_area.queue_free() # So the player can't interact with the nppc anymore
#		else:
#			say_something_timer.queue_free()
	)

	if not dialogues_asking_for_help.is_empty():
		say_something_timer = Timer.new()
		say_something_timer.one_shot = true
		say_something_timer.timeout.connect(_on_say_something_timer_timeout)
		add_child(say_something_timer)
		
		room.player_entered.connect(func() -> void:
			_on_say_something_timer_timeout()
		)

	room.cleared.connect(func() -> void:
		room_cleared=true
	)

	character.dialogue_texts = dialogues_asking_for_help

	character.interact_area.player_interacted.disconnect(character._on_player_interacted)

	jail_interact_area.player_interacted.connect(_on_jail_interacted)

	room.last_enemy_died.connect(func(enemy: Enemy) -> void:
		var key_scene: PackedScene=load("res://items/ShopManagerJailKey.tscn")
		var key: JailKey=key_scene.instantiate()
		key.position=enemy.global_position
		get_tree().current_scene.call_deferred("add_child", key)
		await get_tree().process_frame
		key.go_to_player()

		Globals.player.on_current_room_changed.connect(func(new_room: DungeonRoom) -> void:
			if new_room != null and new_room != room:
				Log.debug("Freeing " + name)
				queue_free()
		)
	)

func _on_say_something_timer_timeout() -> void:
	if character.dialogue_box == null:
		character.start_dialogue()
		await character.dialogue_finished
	if is_instance_valid(say_something_timer):
		say_something_timer.start(randf_range(2.0, 5.0))

#func _on_player_interacted() -> void:
#	# interact_area.queue_free()
#	pass

func _on_jail_interacted() -> void:
	if room_cleared:
		static_body.queue_free()
		$JailBack.queue_free()
		$JailFront.queue_free()
		SavedData.add_ignored_room(room.scene_file_path)
		#character.interact_area.player_interacted.connect(_on_player_interacted)
		character.dialogue_texts = dialogues_after_saving
		character.interact_area.player_interacted.connect(character._on_player_interacted)
