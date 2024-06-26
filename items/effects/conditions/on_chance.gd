class_name OnChance extends ItemEffectsCondition

## Chance represents the percentage of the effects activating, between 0 and 100
var _chance: float

@warning_ignore("shadowed_variable")
func _init(chance: float, effects: Array[ItemEffect], enable_times_limit: int=- 1) -> void:
	super(effects, enable_times_limit)
	_chance = chance

@warning_ignore("shadowed_variable")
func enable(player: Player) -> void:
	super(player)

	if randi_range(0, 100) < _chance:
		_enable_effects()