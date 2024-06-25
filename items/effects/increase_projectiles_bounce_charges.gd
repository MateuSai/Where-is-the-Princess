class_name IncreaseProjectilesBounceCharges extends ItemEffect

var _amount: int

func _init(amount: float) -> void:
	_amount = amount

func enable(player: Player) -> void:
	var projectiles: Array[Node] = player.get_tree().get_nodes_in_group("projectiles")
	for projectile: Node in projectiles:
		(projectile as Projectile).bounces_remaining += _amount

	Projectile.initial_extra_bounce_charges += _amount

func disable(_player: Player) -> void:
	Projectile.initial_extra_bounce_charges -= _amount
