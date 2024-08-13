class_name WeaponItem extends Item

var weapon: Weapon

@warning_ignore("shadowed_variable")
func initialize(weapon: Weapon) -> void:
	self.weapon = weapon

func pick_up(player: Player) -> void:
	player.get_tree().current_scene.add_child(weapon)
	weapon._on_PlayerDetector_body_entered(player)
	weapon = null

func can_pick_up(player: Player) -> bool:
	return player.weapons.get_child_count() < player.weapons.max_weapons and not player.weapons.current_weapon.is_busy()

func get_icon() -> Texture2D:
	var data: WeaponData = Weapon.get_data(weapon.scene_file_path)
	return data.prop

func get_item_name() -> String:
	return Weapon.get_id_from_path(weapon.scene_file_path).to_upper()

func get_item_description() -> String:
	return ""

func get_coin_cost() -> int:
	return 20

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if weapon != null:
			weapon.queue_free()
