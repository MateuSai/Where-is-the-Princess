class_name ThiefDagger extends MeleeWeapon

func _perform_active_ability() -> void:
    (get_parent().get_parent() as Character).velocity += Vector2.RIGHT.rotated(rotation) * 500
