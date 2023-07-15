class_name WeaponHitbox extends Hitbox


func _on_Hitbox_area_entered(area: Area2D) -> void:
	area.queue_free()


func _collide(body: Node2D, _dam: int = damage) -> void:
	super(body, damage * Globals.player.damage_multiplier)
