class_name TutorialForestAttackPracticeRoom extends DungeonRoom

var attacked: bool = false
var active_ability_used: bool = false

func _ready() -> void:
	super()

	await rooms.game.player_added

	player_entered.connect(func() -> void:
		_close_entrance()
		(Globals.player.weapons.get_child(1) as MeleeWeapon).condition_changed.connect(_on_player_weapon_condition_changed)
	, CONNECT_ONE_SHOT)

	Globals.player.weapons.normal_attacked.connect(func() -> void:
		attacked=true
		if active_ability_used:
			_open_doors()
			(Globals.player.weapons.get_child(1) as MeleeWeapon).condition_changed.disconnect(_on_player_weapon_condition_changed)
	, CONNECT_ONE_SHOT)
	Globals.player.weapons.active_ability_used.connect(func() -> void:
		active_ability_used=true
		if attacked:
			_open_doors()
			(Globals.player.weapons.get_child(1) as MeleeWeapon).condition_changed.disconnect(_on_player_weapon_condition_changed)
	, CONNECT_ONE_SHOT)

func _on_player_weapon_condition_changed(weapon: Weapon, new_condition: float) -> void:
	if new_condition < 10:
		weapon.stats.condition = 10
