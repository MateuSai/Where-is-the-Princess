class_name NonPlayerProjectileSpeedMultiplier extends ItemEffect

const EFFECT_SCENE: PackedScene = preload ("res://items/Passive/Permanent/projectile_orb_effect.tscn")

var _effect_active: bool = false
var _can_use: bool = true

var amount: float

func _init(amount: float) -> void:
	self.amount = amount

func enable(player: Player) -> void:
	if _can_use:
		_effect_active = true
		_can_use = false
		Projectile.non_player_projectile_speed_multiplier *= amount

		var effect: Sprite2D = EFFECT_SCENE.instantiate()
		player.add_child(effect)
		(effect.get_node("AnimationPlayer") as AnimationPlayer).animation_finished.connect(func(_anim_name: String) -> void:
			disable(player)
			_effect_active=false

			await player.get_tree().create_timer(30).timeout
			_can_use=true
		)

func disable(_player: Player) -> void:
	if _effect_active:
		Projectile.non_player_projectile_speed_multiplier /= amount