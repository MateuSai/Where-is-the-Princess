class_name WeaponItem extends Item

var weapon: Weapon


@warning_ignore("shadowed_variable")
func initialize(weapon: Weapon) -> void:
	self.weapon = weapon


func pick_up(player: Player) -> void:
	player.get_tree().current_scene.add_child(weapon)
	weapon._on_PlayerDetector_body_entered(player)
	weapon = null


func get_icon() -> Texture2D:
	var data: WeaponData = Weapon.get_data(weapon.scene_file_path)
	return data.prop


func get_item_name() -> String:
	return Weapon.get_id_from_path(weapon.scene_file_path).to_upper()


func get_item_description() -> String:
	return ""


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if weapon != null:
			weapon.queue_free()
