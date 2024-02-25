extends PermanentPassiveItem

const EFFECT_SCENE: PackedScene = preload("res://items/Passive/Permanent/projectile_orb_effect.tscn")

var effect_active: bool = false
var can_use: bool = true


func get_icon() -> Texture2D:
	return load("res://Art/items/gravitational_orb_anim.tres")


func equip(player: Player) -> void:
	player.life_component.damage_taken.connect(func(_dam: int, _dir: Vector2, _force: int) -> void:
		if player.life_component.last_is_projectile and can_use:
			effect_active = true
			can_use = false
			Projectile.non_player_projectile_speed_multiplier *= 0.5

			var effect: Sprite2D = EFFECT_SCENE.instantiate()
			player.add_child(effect)
			(effect.get_node("AnimationPlayer") as AnimationPlayer).animation_finished.connect(func(_anim_name: String) -> void:
				unequip(player)
				effect_active = false

				await player.get_tree().create_timer(30).timeout
				can_use = true
			)
	)


func unequip(_player: Player) -> void:
	if effect_active:
		Projectile.non_player_projectile_speed_multiplier /= 0.5
