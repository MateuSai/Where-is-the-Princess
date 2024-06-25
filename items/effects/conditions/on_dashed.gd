class_name OnDashed extends ItemEffectsCondition

func enable(player: Player) -> void:
	super(player)

	player.dashed.connect(_on_dashed)

func disable(player: Player) -> void:
	super(player)

	player.dashed.disconnect(_on_dashed)

func _on_dashed(_dash_time: float) -> void:
	_enable_effects()