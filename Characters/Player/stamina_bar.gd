extends TextureProgressBar

## With a scale of 0.3 and a max stamina of 100, the width would be 0.3 * 100 = 30 pixels
const SCALE: float = 0.59

@onready var player: Player = owner
@onready var nine_patch: NinePatchRect = get_node("%StaminaNinePatch")
@onready var update_timer: Timer = $UpdateTimer

func _ready() -> void:
	update_timer.timeout.connect(_update)

	player.max_stamina_changed.connect(_on_max_stamina_changed)
	_on_max_stamina_changed(100)

func _update() -> void:
	value = player.stamina

func _on_max_stamina_changed(new_max_stamina: float) -> void:
	max_value=new_max_stamina
	nine_patch.custom_minimum_size.x=max_value * SCALE
