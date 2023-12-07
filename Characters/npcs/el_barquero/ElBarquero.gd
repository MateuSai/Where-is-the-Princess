class_name ElBarquero extends NPC

@onready var room: DungeonRoom = get_parent()


func _ready() -> void:
	if room.has_node("PlayerSpawnPos"):
		super() # Talk when player interacts
	else:
		# Change level
		interact_area.player_interacted.connect(func() -> void:
			Globals.exit_level()
		)
