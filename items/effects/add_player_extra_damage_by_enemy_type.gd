class_name AddPlayerExtraDamageByEnemyType extends ItemEffect

var _id: String
var _amount: int

func _init(id: String, amount: int) -> void:
	_id = id
	_amount = amount

func enable(player: Player) -> void:
	player.life_component.add_extra_damage_by_enemy_id(_id, _amount)

func disable(player: Player) -> void:
	player.life_component.remove_extra_damage_by_enemy_id(_id, _amount)

func get_description() -> String:
	return _get_color_tag(GREEN if _amount < 0 else RED) % (tr("EXTRA_DAMAGE_BY_ENEMY_TYPE") % [str(_amount), tr(_id.to_snake_case().to_upper())])
