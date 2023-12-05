class_name OptionButtonWithSound extends OptionButton


func _ready() -> void:
	pressed.connect(func() -> void:
		var sound: AudioStreamPlayer = AudioStreamPlayer.new()
		sound.stream = load("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Click-Button-Switch/Click8.wav")
		sound.bus = "Sounds"
		sound.finished.connect(sound.queue_free)
		get_tree().current_scene.add_child(sound)
		sound.play()
	)
