class_name OnPlayerDamaged extends ItemEffectsCondition

var ranged_only: bool

func _init(effects: Array[ItemEffect]=[], enable_times_limit: int=- 1, ranged_only: bool=false) -> void:
    super(effects, enable_times_limit)
    self.ranged_only = ranged_only

@warning_ignore("shadowed_variable")
func enable(player: Player) -> void:
    super(player)

    player.life_component.damage_taken.connect(_on_player_damage_taked)

@warning_ignore("shadowed_variable")
func disable(player: Player) -> void:
    super(player)

    player.life_component.damage_taken.disconnect(_on_player_damage_taked)

func _on_player_damage_taked(_dam: int, _dir: Vector2, _force: int) -> void:
    if ranged_only and not player.life_component.last_is_ranged:
        return

    _enable_effects()