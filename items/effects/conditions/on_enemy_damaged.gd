class_name OnEnemyDamaged extends ItemEffectsCondition

@warning_ignore("shadowed_variable")
func enable(player: Player) -> void:
    super(player)

    Globals.character_received_damage.connect(_on_character_received_damage)

@warning_ignore("shadowed_variable")
func disable(player: Player) -> void:
    super(player)

    Globals.character_received_damage.disconnect(_on_character_received_damage)

func _on_character_received_damage(character: Character, damage_dealer: Character) -> void:
    if not character is Player and damage_dealer is Player:
        _enable_effects()

func get_description() -> String:
    return "%s\n%s" % [tr("ON_ENEMY_DAMAGED"), super()]