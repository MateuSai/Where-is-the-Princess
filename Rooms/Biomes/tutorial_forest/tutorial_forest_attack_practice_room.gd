extends DungeonRoom

var attacked: bool = false
var active_ability_used: bool = false

func _ready() -> void:
	await rooms.game.player_added

	player_entered.connect(func() -> void:
		_close_entrance()
	, CONNECT_ONE_SHOT)

	Globals.player.weapons.normal_attacked.connect(func() -> void:
		attacked=true
		if active_ability_used:
			_open_doors()
	, CONNECT_DEFERRED)
	Globals.player.weapons.active_ability_used.connect(func() -> void:
		active_ability_used=true
		if attacked:
			_open_doors()
	, CONNECT_ONE_SHOT)
