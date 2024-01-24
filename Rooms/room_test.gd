class_name RoomTest extends Game


static var room_path: String = ""

#@onready var rooms: Node2D = $Rooms


func _ready() -> void:
	assert(not room_path.is_empty())

	var room: DungeonRoom = load(room_path).instantiate()
	rooms.add_child(room)
	room.generate_room_white_image()
	room.setup_navigation()

	var player: Player = load("res://Characters/Player/Player.tscn").instantiate()
	add_child(player)
	player.position = room.teleport_position.global_position

	room._on_player_entered_room()
