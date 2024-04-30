class_name CharacterInDanger extends Node2D

@export var dialogues_asking_for_help: PackedStringArray = ["HELP ME!", "Help, these creatures want to eat me", "The coolest asset pack out there"]
@export var dialogues_after_saving: PackedStringArray = ["Thanks", "I was about to get free by myself, but thanks anyway", "I'm free, hahahaah. Now I can continue with my reptilian genocide"]

var room_cleared: bool = false
var say_something_timer: Timer

@onready var room: DungeonRoom = owner

@onready var character: NPC = $Character
@onready var static_body: StaticBody2D = $StaticBody2D
@onready var jail_interact_area: InteractArea = $StaticBody2D/InteractArea

func _ready() -> void:
	character.dialogues_in_order = true

	character.used_all_dialogues.connect(func() -> void:
		if room_cleared:
			if is_instance_valid(say_something_timer):
				say_something_timer.queue_free()

			character.interact_area.queue_free() # So the player can't interact with the nppc anymore
			
			Globals.player.on_current_room_changed.connect(func(new_room: DungeonRoom) -> void:
				if new_room != null and new_room != room:
					print_debug("Freeing " + name)
					queue_free()
			)
		else:
			say_something_timer.queue_free()
	)

	say_something_timer = Timer.new()
	say_something_timer.one_shot = true
	say_something_timer.timeout.connect(_on_say_something_timer_timeout)
	add_child(say_something_timer)

	room.cleared.connect(func() -> void:
		room_cleared=true
	)

	character.dialogue_texts = dialogues_asking_for_help

	room.player_entered.connect(func() -> void:
		_on_say_something_timer_timeout()
	)

	character.interact_area.player_interacted.disconnect(character._on_player_interacted)

	jail_interact_area.player_interacted.connect(_on_jail_interacted)

	room.last_enemy_died.connect(func(enemy: Enemy) -> void:
		var key_scene: PackedScene=load("res://items/ShopManagerJailKey.tscn")
		var key: JailKey=key_scene.instantiate()
		key.position=enemy.global_position
		get_tree().current_scene.call_deferred("add_child", key)
		await get_tree().process_frame
		key.go_to_player()
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
