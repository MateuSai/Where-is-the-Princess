class_name OnPlayerDamaged extends ItemEffectsCondition

@warning_ignore("shadowed_variable")
func enable(player: Player) -> void:
    super(player)

    player.life_component.damage_taken.connect(_on_player_damage_taked)

@warning_ignore("shadowed_variable")
func disable(player: Player) -> void:
    super(player)

    player.life_component.damage_taken.disconnect(_on_player_damage_taked)

func _on_player_damage_taked(_dam: int, _dir: Vector2, _force: int) -> void:
    _enable_effects()