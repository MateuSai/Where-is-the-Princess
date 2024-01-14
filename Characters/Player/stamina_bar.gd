extends TextureProgressBar


@onready var player: Player = owner
@onready var update_timer: Timer = $UpdateTimer


func _ready() -> void:
	update_timer.timeout.connect(_update)


func _update() -> void:
	value = player.stamina
