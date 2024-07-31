class_name ProjectileOrbCursed extends CursedPermanentArtifact

func _init() -> void:
	effects = [OnPlayerDamaged.new(
		[
			OnCooldown.new(
				30,
				[DisableAfter.new(5.04,
					[
						NonPlayerProjectileSpeedMultiplier.new(0.3),
						IncreaseProjectilesBounceCharges.new(1),
						SpawnSceneAsPlayerChild.new(
							load("res://items/Passive/Permanent/cursed/projectile_orb_cursed_effect.tscn")
						)
					]
				)]
			)

		],
			- 1,
			true
	)]

func get_icon() -> Texture2D:
	return load("res://Art/items/gravitational_orb_cursed_anim.tres")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/gravitational_orb_cursed_UI_desc.png")