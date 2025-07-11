class_name OnDashed extends ItemEffectsCondition

@warning_ignore("shadowed_variable")
func enable(player: Player) -> void:
	super(player)

	player.dashed.connect(_on_dashed)

@warning_ignore("shadowed_variable")
func disable(player: Player) -> void:
	super(player)

	player.dashed.disconnect(_on_dashed)

func _on_dashed(_dash_time: float) -> void:
	_enable_effects()

func get_description() -> String:
	return "%s\n%s" % [tr("ON_DASHED"), super()]
