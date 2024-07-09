class_name GameMusic extends AudioStreamPlayer

const VOLUME_DIF: int = 6

@onready var game: Game = owner

func _ready() -> void:
	game.game_paused.connect(func() -> void:
		volume_db -= VOLUME_DIF
	)
	game.game_unpaused.connect(func() -> void:
		volume_db += VOLUME_DIF
	)
