class_name TutorialForestJumpTutorial extends DungeonRoom

@onready var chest: Chest = $Chest

func _ready() -> void:
	super()

	await rooms.game.player_added

	player_entered.connect(func() -> void:
		_close_entrance()

		Globals.player.armor_changed.connect(func(_armor: Armor) -> void:
			_open_doors()
		, CONNECT_ONE_SHOT)
	, CONNECT_ONE_SHOT)
