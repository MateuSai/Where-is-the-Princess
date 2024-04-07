class_name ItemEffectsCondition extends ItemEffect

var effects: Array[ItemEffect]

var in_effect: bool = false

var player: Player

@warning_ignore("shadowed_variable")
func _init(effects: Array[ItemEffect]) -> void:
    self.effects = effects

@warning_ignore("shadowed_variable")
func enable(player: Player) -> void:
    self.player = player

func disable(_player: Player) -> void:
    if in_effect:
        _disable_effects()

func _enable_effects() -> void:
    in_effect = true

    for effect: ItemEffect in effects:
        effect.enable(player)

func _disable_effects() -> void:
    in_effect = false

    for effect: ItemEffect in effects:
        effect.disable(player)