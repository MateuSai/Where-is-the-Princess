class_name WeaponItem extends Item

var weapon: Weapon


@warning_ignore("shadowed_variable")
func initialize(weapon: Weapon) -> void:
	self.weapon = weapon


func pick_up(player: Player) -> void:
	player.get_tree().current_scene.add_child(weapon)
	weapon._on_PlayerDetector_body_entered(player)
	weapon = null


func get_icon() -> Texture:
	return weapon.get_texture()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if weapon != null:
			weapon.queue_free()
