class_name IncreaseProjectilesBounceCharges extends ItemEffect

var _amount: int

func _init(amount: int) -> void:
	_amount = amount

func enable(player: Player) -> void:
	var projectiles: Array[Node] = player.get_tree().get_nodes_in_group("projectiles")
	for projectile: Node in projectiles:
		(projectile as Projectile).bounces_remaining += _amount

	Globals.global_stats.projectiles_initial_extra_bounce_charges += _amount

func disable(_player: Player) -> void:
	Globals.global_stats.projectiles_initial_extra_bounce_charges -= _amount

func get_description() -> String:
	return _get_color_tag(YELLOW) % (tr("INCREASE_PROJECTILES_BOUNCE_CHARGES") % _amount)