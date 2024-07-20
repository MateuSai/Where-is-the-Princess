class_name WeaponCharge extends ActionLeaf

var _charging: bool = false
var _finished_charging: bool = false

@onready var enemy_weapons: EnemyWeapons = owner.get_node("EnemyWeapons")

func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if _finished_charging:
		_charging = false
		_finished_charging = false
		return SUCCESS
	if _charging:
		return RUNNING
	if enemy_weapons.is_busy():
		return FAILURE

	_charging = true
	enemy_weapons.current_weapon._charge()
	enemy_weapons.current_weapon.animation_player.animation_finished.connect(func(_anim_name: String) -> void:
		_finished_charging = true
	, CONNECT_ONE_SHOT)

	return RUNNING
