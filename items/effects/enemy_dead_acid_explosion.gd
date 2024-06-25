class_name EnemyDeadAcidExplosion extends ItemEffect

func enable(_player: Player) -> void:
	Enemy.dead_acid_explosion += 1

func disable(_player: Player) -> void:
	Enemy.dead_acid_explosion -= 1