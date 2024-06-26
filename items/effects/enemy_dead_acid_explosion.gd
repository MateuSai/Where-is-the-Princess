class_name EnemyDeadAcidExplosion extends ItemEffect

func enable(_player: Player) -> void:
	Enemy.dead_acid_explosion += 1

func disable(_player: Player) -> void:
	Enemy.dead_acid_explosion -= 1

func get_description() -> String:
	return _get_color_tag(YELLOW) % "Enemy acid explosion on dead"
