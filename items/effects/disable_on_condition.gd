class_name DisableOnCondition extends ItemEffect

var condition: ItemEffectsCondition
var condition_to_disable: ItemEffectsCondition

@warning_ignore("shadowed_variable")
func _init(condition: ItemEffectsCondition, condition_to_disable: ItemEffectsCondition) -> void:
    self.condition = condition
    self.condition_to_disable = condition_to_disable

func enable(player: Player) -> void:
    condition.effects_enabled.connect(_on_condition_meet)

    condition.enable(player)
    condition_to_disable.enable(player)

func disable(player: Player) -> void:
    condition.effects_enabled.disconnect(_on_condition_meet)

    condition.disable(player)
    condition_to_disable.disable(player)

func _on_condition_meet() -> void:
    condition_to_disable._disable_effects()