@icon("res://Art/weapons/spear.png")
class_name ThrowableWeapon extends MeleeWeapon

var throw_dir: Vector2


func _ready() -> void:
	super()
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	position += throw_dir * 400 * delta


func throw() -> void:
	throw_dir = Vector2.RIGHT.rotated(weapon_sprite.global_rotation - PI/4) if scale.y == 1 else Vector2.RIGHT.rotated(weapon_sprite.global_rotation + PI/4)
	get_parent().throw_weapon()
	hitbox.get_node("CollisionShape2D").disabled = false
	hitbox.set_collision_mask_value(1, true) # Para que pueda colisionar con paredes
	hitbox.body_entered.disconnect(hitbox._on_body_entered)
	hitbox.body_entered.connect(throw_body_entered_hitbox)
	set_physics_process(true)


func throw_body_entered_hitbox(body: Node2D) -> void:
		if body is Enemy:
			hitbox._on_body_entered(body)
		else:
			_on_collided_with_something()
		_on_Tween_tween_completed()
		# Back to previous state
		hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)
		hitbox.set_collision_mask_value(1, false) # Para que NO pueda colisionar con paredes
		hitbox.body_entered.disconnect(throw_body_entered_hitbox)
		hitbox.body_entered.connect(hitbox._on_body_entered)
		set_physics_process(false)
