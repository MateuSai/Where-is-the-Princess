@icon("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/weapon icons/wooden_bow_icon.png")
class_name BowOrCrossbowWeapon extends RangedWeapon


signal arrow_type_changed(new_type: Arrow.Type)
var arrow_type: Arrow.Type = Arrow.Type.NORMAL:
	set(new_type):
#		print("New arrow type is: " + Arrow.Type.keys()[new_type])
		arrow_type = new_type
		arrow_type_changed.emit(arrow_type)


func _spawn_projectile(angle: float = 0.0, amount: int = 1, rotate_to_dir: bool = true) -> Array[Projectile]:
	var spawned_projectiles: Array[Projectile] = super(angle, amount, rotate_to_dir)

	for projectile: Projectile in spawned_projectiles:
		assert(projectile is ArrowOrBolt)
		projectile.type = arrow_type

		for modifier: WeaponModifier in stats.modifiers:
			if not modifier is StatusWeaponModifier:
				continue
			@warning_ignore("unsafe_call_argument")
			var status_inflicter_component: StatusInflicterComponent = projectile.get_node_or_null(StatusComponent.Status.keys()[modifier.status] + "Inflicter")
			if status_inflicter_component:
				status_inflicter_component.change_to_inflict_status_effect += StatusWeaponModifier.INFLICT_CHANCE
			else:
				status_inflicter_component = StatusInflicterComponent.new()
				status_inflicter_component.status = modifier.status
				status_inflicter_component.change_to_inflict_status_effect = StatusWeaponModifier.INFLICT_CHANCE * amount
				status_inflicter_component.name = StatusComponent.Status.keys()[modifier.status] + "Inflicter"
				projectile.add_child(status_inflicter_component)

	return spawned_projectiles


func add_status_inflicter(status: StatusComponent.Status, amount: int=1) -> void:
	for i: int in amount:
		status_inflicter_added.emit(self, status)
