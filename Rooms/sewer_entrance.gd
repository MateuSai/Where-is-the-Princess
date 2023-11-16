class_name SewerEntrance extends StaticBody2D


func _ready() -> void:
	$InteractArea.player_interacted.connect(func():
		Globals.exit_level("sewer")
	)
