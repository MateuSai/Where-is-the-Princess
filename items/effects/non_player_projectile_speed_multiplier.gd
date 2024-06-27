class_name NonPlayerProjectileSpeedMultiplier extends ItemEffect

#const EFFECT_SCENE: PackedScene = preload ("res://items/Passive/Permanent/projectile_orb_effect.tscn")

var _effect_active: bool = false

var _amount: float

func _init(amount: float) -> void:
	self._amount = amount

func enable(_player: Player) -> void:
	_effect_active = true
	Projectile.non_player_projectile_speed_multiplier *= _amount

	#var effect: Sprite2D = EFFECT_SCENE.instantiate()
	#player.add_child(effect)
	#(effect.get_node("AnimationPlayer") as AnimationPlayer).animation_finished.connect(func(_anim_name: String) -> void:
	#	disable(player)
	#	_effect_active=false
	#)

func disable(_player: Player) -> void:
	if _effect_active:
		Projectile.non_player_projectile_speed_multiplier /= _amount

func get_description() -> String:
	return _get_color_tag(GREEN if _amount < 1 else RED) % (tr("NON_PLAYER_PROJECTILE_SPEED_MULTIPLIER") % str((1 - _amount) * 100))