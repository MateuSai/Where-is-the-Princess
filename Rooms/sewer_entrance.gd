class_name SewerEntrance extends StaticBody2D


func _ready() -> void:
	($InteractArea as InteractArea).player_interacted.connect(func() -> void:
		Globals.exit_level("sewer")
	)
