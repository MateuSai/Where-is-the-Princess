extends ButtonWithSound

func _ready() -> void:
    super()

    pressed.connect(func() -> void:
        OS.shell_open("https://wekufustudios.github.io/")
    )
