## Melee weapon hitbox
class_name WeaponHitbox extends Hitbox

func _ready() -> void:
	super()

func _collide(body: Node2D, _dam: int=damage) -> void:
	if damage_dealer is Player:
		assert(weapon)
		if weapon.stats.condition - weapon.data.condition_cost_per_normal_attack <= 0:
			damage += (damage_dealer as Player).weapons.extra_damage_when_weapon_breaks

	if damage_dealer is Player:
		super(body, damage * Globals.player.damage_multiplier)
	else:
		super(body, damage)
