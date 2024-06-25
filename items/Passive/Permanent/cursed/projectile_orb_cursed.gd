class_name ProjectileOrbCursed extends CursedPermanentPassiveItem

func _init() -> void:
	effects = [OnPlayerDamaged.new(
		[
			NonPlayerProjectileSpeedMultiplier.new(0.5)
		],
			- 1,
			true
	)]

func get_icon() -> Texture2D:
	return load("res://Art/items/gravitational_orb_anim.tres")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/gravitational_orb_cursed_UI_desc.png")