class_name PointWeaponToTarget extends ActionLeaf

@onready var aim_component: AimComponent = owner.get_node_or_null("AimComponent")
@onready var enemy_weapons: EnemyWeapons = owner.get_node("EnemyWeapons")

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if aim_component:
		if enemy_weapons.current_weapon is RangedWeapon:
			enemy_weapons.move(aim_component.get_dir(enemy_weapons.current_weapon.spawn_projectile_pos.global_position).dir)
		else:
			enemy_weapons.move(aim_component.get_dir().dir)
	else:
		enemy_weapons.move(((actor as Enemy).target.global_position - (actor as Enemy).global_position).normalized())

	return SUCCESS
