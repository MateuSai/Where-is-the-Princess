class_name DisableAfter extends ItemEffectsCondition

var _time: float

var _can_enable: bool = true

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
		_disable_effects()

func get_description() -> String:
	return "%s\n%s" % [tr("DISABLE_AFTER") % str(_time), super()]