extends ButtonWithSound

func _ready() -> void:
    pressed.connect(func() -> void:
        OS.shell_open("https://discord.gg/nVcwyvnB")
    )
