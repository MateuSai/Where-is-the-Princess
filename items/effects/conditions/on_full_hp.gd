class_name OnFullHP extends ItemEffectsCondition

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
    if new_hp == player.life_component.max_hp:
        _enable_effects()
    elif in_effect:
        _disable_effects()

func get_description() -> String:
    return "%s\n%s" % [tr("ON_FULL_HP"), super()]