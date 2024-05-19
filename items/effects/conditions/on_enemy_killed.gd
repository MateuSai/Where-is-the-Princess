class_name OnEnemyKilled extends ItemEffectsCondition

@warning_ignore("shadowed_variable")
func enable(player: Player) -> void:
    super(player)

    Globals.character_received_damage.connect(_on_character_received_damage)

@warning_ignore("shadowed_variable")
func disable(player: Player) -> void:
    super(player)

    Globals.character_received_damage.disconnect(_on_character_received_damage)

func _on_character_received_damage(character: Character, damage_dealer: Node) -> void:
    if not character is Player and damage_dealer is Player:
        if character is Enemy and (character as Enemy).life_component.hp == 0:
            _enable_effects()