class_name NonPlayerProjectileSpeedMultiplier extends ItemEffect

const EFFECT_SCENE: PackedScene = preload ("res://items/Passive/Permanent/projectile_orb_effect.tscn")

var _effect_active: bool = false

var amount: float

func _init(amount: float) -> void:
	self.amount = amount

func enable(player: Player) -> void:
	_effect_active = true
	Projectile.non_player_projectile_speed_multiplier *= amount

	var effect: Sprite2D = EFFECT_SCENE.instantiate()
	player.add_child(effect)
	#(effect.get_node("AnimationPlayer") as AnimationPlayer).animation_finished.connect(func(_anim_name: String) -> void:
	#	disable(player)
	#	_effect_active=false
	#)

func disable(_player: Player) -> void:
	if _effect_active:
		Projectile.non_player_projectile_speed_multiplier /= amount
