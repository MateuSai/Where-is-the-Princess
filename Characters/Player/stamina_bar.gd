extends TextureProgressBar


@onready var player: Player = owner
@onready var update_timer: Timer = $UpdateTimer


func _ready() -> void:
	update_timer.timeout.connect(_update)

	player.max_stamina_changed.connect(func(new_value: float) -> void:
		max_value = new_value
	)


func _update() -> void:
	value = player.stamina
