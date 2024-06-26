class_name OnCooldown extends ItemEffectsCondition

var _can_enable: bool = true

var _time: float

@warning_ignore("shadowed_variable")
func _init(time: float, effects: Array[ItemEffect], enable_times_limit: int=- 1) -> void:
	super(effects, enable_times_limit)

	_time = time

@warning_ignore("shadowed_variable")
func enable(player: Player) -> void:
	super(player)

	if _can_enable:
		_can_enable = false
		_enable_effects()
		await player.get_tree().create_timer(_time).timeout
		_can_enable = true
