class_name IceStatusComponent extends StatusComponent

var status_timer: Timer

const ATTACKS_TO_BREAK_ICE: int = 3
var player_attacks_when_frozen: int = 0

func _ready() -> void:
	super()

	var ice_cube_sprite: Sprite2D = Sprite2D.new()
	ice_cube_sprite.texture = load("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Skeleton/archeleton_icon.png")
	add_child(ice_cube_sprite)

	set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_attack"):
		player_attacks_when_frozen += 1
		if player_attacks_when_frozen >= ATTACKS_TO_BREAK_ICE:
			set_process_unhandled_input(false)
			remove()

func add() -> void:
	character.modulate = Color.DEEP_SKY_BLUE

	player_attacks_when_frozen = 0

	set_process_unhandled_input(true)

	super()

func remove() -> void:
	character.modulate = Color.WHITE
	super()
