class_name TutorialForestCombatRoom extends DungeonRoom

var default_set_hp_function: Callable

func _ready() -> void:
	super()

	await rooms.game.player_added

	closed.connect(func() -> void:
		default_set_hp_function=Globals.player.life_component._set_hp
		Globals.player.life_component._set_hp=_player_set_hp
	)
	cleared.connect(func() -> void:
		Log.debug("Room cleared")
		Globals.player.life_component._set_hp=default_set_hp_function
	)

func _player_set_hp(new_hp: int) -> void:
	if new_hp <= 0:
		Globals.player.life_component.hp = 4

		reset()

		return

	default_set_hp_function.call(new_hp)