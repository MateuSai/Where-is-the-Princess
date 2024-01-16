class_name ExitLevelOnInteract extends InteractArea


@export var biome: String = ""


func _ready() -> void:
	super()

	player_interacted.connect(func() -> void:
		Globals.exit_level(biome)
	)
