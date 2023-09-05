class_name CharacterInDanger extends Node2D

@export var dialogues_asking_for_help: PackedStringArray = ["HELP ME!", "Help, these creatures want to eat me"]
@export var dialogues_after_saving: PackedStringArray = ["Thanks", "I was about to get free by myself, but thanks anyway", "I'm free, hahahaah. Now I can continue with my reptilian genocide"]

var room_cleared: bool = false
var say_something_timer: Timer

var character_is_free: bool = false

@onready var room: DungeonRoom = owner

@onready var character: NPC = get_child(0)


func _ready() -> void:
	say_something_timer = Timer.new()
	say_something_timer.one_shot = true
	say_something_timer.timeout.connect(func():
		character.start_dialogue()
		await character.dialogue_finished
		say_something_timer.start(randf_range(3.0, 6.0))
	)
	add_child(say_something_timer)

	room.cleared.connect(func():
		room_cleared = true
	)

	character.interact_area.player_interacted.connect(_on_player_interacted)

	character.dialogue_texts = dialogues_asking_for_help

	room.player_entered.connect(func():
		say_something_timer.start(randf_range(3.0, 6.0))
	)


func _on_player_interacted() -> void:
	if room_cleared:
		if not character_is_free:
			character_is_free = true
			# interact_area.queue_free()
			character.dialogue_texts = dialogues_after_saving
			SavedData.add_ignored_room(room.scene_file_path)
