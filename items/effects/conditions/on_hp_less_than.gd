class_name OnHpLessThan extends ItemEffectsCondition

var less_than: int

@warning_ignore("shadowed_variable")
func _init(less_than: int, effects: Array[ItemEffect]) -> void:
    self.less_than = less_than
    
    super(effects)

@warning_ignore("shadowed_variable")
func enable(player: Player) -> void:
    super(player)
    
    player.life_component.hp_changed.connect(_on_hp_changed)
    
    _on_hp_changed(player.life_component.hp)

@warning_ignore("shadowed_variable")
func disable(player: Player) -> void:
    super(player)

    player.life_component.hp_changed.disconnect(_on_hp_changed)

func _on_hp_changed(new_hp: int) -> void:
    if new_hp < less_than and not in_effect:
        _enable_effects()
    elif in_effect and new_hp >= less_than:
        _disable_effects()