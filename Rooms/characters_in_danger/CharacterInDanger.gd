class_name CharacterInDanger extends StaticBody2D

var room_cleared: bool = false


@onready var room: DungeonRoom = owner

@onready var interact_area: InteractArea = $InteractArea


func _ready() -> void:
	room.cleared.connect(func():
		room_cleared = true
	)

	interact_area.player_interacted.connect(_on_player_interacted)


func _on_player_interacted() -> void:
	if room_cleared:
		interact_area.queue_free()
		SavedData.add_ignored_room(room.scene_file_path)
