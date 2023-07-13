class_name MeleeWeapon extends Weapon


@export var backwards_animation_second_attack: bool = false
var attack_num: int = 0

enum Type {
	SPEAR,
	SWORD,
}
@export var type: Type
@export var throw_speed: int = 200
var throw_dir: Vector2
var throw_rot_speed: float = 0


func _ready() -> void:
	super()
	hitbox.collided_with_something.connect(func(_body: Node2D):
		_on_collided_with_something()
	)
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	position += throw_dir * throw_speed * delta
	weapon_sprite.rotation += throw_rot_speed * delta


func _on_collided_with_something(col_mat: Hitbox.CollisionMaterial = Hitbox.CollisionMaterial.FLESH) -> void:
	# Double degrade amount if we collide with stone
	stats.set_condition(stats.condition - round(condition_degrade_by_attack * (col_mat+1)))


func _pick_up() -> void:
	super()
	attack_num = 0


func attack() -> void:
	if backwards_animation_second_attack:
		if attack_num == 0:
			attack_num = 1
			super()
		else:
			attack_num = 0
			animation_player.play_backwards("attack")
	else:
		super()


func _charge() -> void:
	if backwards_animation_second_attack:
		#animation_player.play("charge0")
		animation_player.play("charge" + str(attack_num))
	else:
		super()


func _strong_attack() -> void:
	if backwards_animation_second_attack:
		#animation_player.play("charge0")
		animation_player.play("strong_attack" + str(attack_num))
	else:
		super()


func throw() -> void:
	throw_dir = get_parent().get_parent().mouse_direction
	if type == Type.SWORD:
		throw_rot_speed = 25 if attack_num == 0 else -25
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
			_on_collided_with_something(Hitbox.CollisionMaterial.STONE)
		_on_Tween_tween_completed()
		# Back to previous state
		hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)
		hitbox.set_collision_mask_value(1, false) # Para que NO pueda colisionar con paredes
		hitbox.body_entered.disconnect(throw_body_entered_hitbox)
		hitbox.body_entered.connect(hitbox._on_body_entered)
		set_physics_process(false)
