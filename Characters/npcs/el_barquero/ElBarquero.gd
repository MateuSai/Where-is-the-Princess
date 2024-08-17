class_name ElBarquero extends NPC


func _ready() -> void:
	super()

	if room.has_node("PlayerSpawnPos"):
		interact_area.queue_free()
	else:
		# Change level
		interact_area.player_interacted.connect(func() -> void:
			Globals.exit_level()
		)
