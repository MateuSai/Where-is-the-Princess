class_name MeleeWeapon extends Weapon

const CUT_FLESH_SOUNDS: Array[AudioStream] = [preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Sword/MetalSlash1.wav"), preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Sword/MetalSlash2.wav"), preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Sword/MetalSlash3.wav")]
const IMPACT_FLESH_SOUNDS: Array[AudioStream] = [preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Hit(Impact)/HitGore1.wav"), preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Hit(Impact)/HitGore2.wav"), preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Hit(Impact)/HitGore3.wav"), preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Hit(Impact)/HitGore4.wav")]

## This variable indicates wheter the number of normal attacks. They will be used on order. If it has value 2 but only has one attack animation, for the second attack it will use the first animation but backwards, this is used on the Katana for example
@export var num_normal_attacks: int = 1
var attack_num: int = 0:
	set(new_attack_num):
		attack_num = wrapi(new_attack_num, 0, num_normal_attacks)
@export var increase_num_normal_attacks_on_ability: bool = true

## If this is true, the scale will be inverted when looking at the left
@export var invert_scale_when_looking_left: bool = false

@export var throw_speed: int = 200
var throw_dir: Vector2
var throw_rot_speed: float = 0

var piercing: int = 1
var bodies_pierced: int = 0


func _ready() -> void:
	super()
	hitbox.collided_with_something.connect(func(_body: Node2D):
		_on_collided_with_something()
	)
	set_physics_process(false)
	set_process_unhandled_input(false)


func _load_csv_data(data: Dictionary) -> void:
	super(data)

	num_normal_attacks = data["num_normal_attacks"]
	increase_num_normal_attacks_on_ability = bool(data["increase_num_normal_attacks_on_ability"])


func _physics_process(delta: float) -> void:
	position += throw_dir * throw_speed * delta
	weapon_sprite.rotation += throw_rot_speed * delta


func _on_collided_with_something(col_mat: Hitbox.CollisionMaterial = Hitbox.CollisionMaterial.FLESH) -> void:
	# Double degrade amount if we collide with stone
	stats.set_condition(stats.condition - round(condition_cost_per_normal_attack * (col_mat+1)))
	match col_mat:
		Hitbox.CollisionMaterial.FLESH:
			var audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
			audio.bus = "Sounds"
			audio.position = global_position
			audio.volume_db = -8
			match type:
				Type.HAMMER:
					audio.stream = IMPACT_FLESH_SOUNDS[randi() % IMPACT_FLESH_SOUNDS.size()]
				_:
					audio.stream = CUT_FLESH_SOUNDS[randi() % CUT_FLESH_SOUNDS.size()]
			get_tree().current_scene.add_child(audio)
			audio.finished.connect(audio.queue_free)
			audio.play()


func _pick_up() -> void:
	super()
	attack_num = 0


func attack() -> void:
	if attack_num == 1 and not animation_player.has_animation("attack_2"):
		animation_player.play_backwards("attack_1")
	else:
		animation_player.play("attack_" + str(attack_num + 1))
	attack_num += 1


func _charge() -> void:
	animation_player.play("charge_" + str(attack_num + 1))


func _strong_attack() -> void:
	animation_player.play("strong_attack_" + str(attack_num + 1))


func _active_ability(_animation_name: String = "active_ability") -> void:
	super("active_ability_" + str(attack_num + 1))
	if increase_num_normal_attacks_on_ability:
		attack_num += 1


func throw() -> void:
	throw_dir = get_parent().get_parent().mouse_direction
	bodies_pierced = 0
	piercing = get_parent().get_parent().throw_piercing
	if type == Type.SWORD:
		throw_rot_speed = 25 if attack_num == 0 else -25
	get_parent().throw_weapon()
	hitbox.get_node("CollisionShape2D").disabled = false
	hitbox.set_collision_mask_value(1, true) # Para que pueda colisionar con paredes
	hitbox.body_entered.disconnect(hitbox._on_body_entered)
	hitbox.body_entered.connect(_throw_body_entered_hitbox)
	hitbox.area_entered.disconnect(hitbox._on_area_entered)
	hitbox.area_entered.connect(_throw_body_entered_hitbox)
	set_physics_process(true)


func _throw_body_entered_hitbox(body: Node2D) -> void:
	body = hitbox._get_entity(body)
	if body is Enemy:
		hitbox._on_body_entered(body)
		bodies_pierced += 1
		if bodies_pierced < piercing:
			return # We don't stop the weapon yet
	else:
		_on_collided_with_something(Hitbox.CollisionMaterial.STONE)
	_go_back_to_before_throw_state()


func _go_back_to_before_throw_state() -> void:
	_on_Tween_tween_completed()
	# Back to previous state
	hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)
	hitbox.set_collision_mask_value(1, false) # Para que NO pueda colisionar con paredes
	hitbox.body_entered.disconnect(_throw_body_entered_hitbox)
	hitbox.body_entered.connect(hitbox._on_body_entered)
	hitbox.area_entered.disconnect(_throw_body_entered_hitbox)
	hitbox.area_entered.connect(hitbox._on_area_entered)
	set_physics_process(false)


func add_status_inflicter(status: StatusComponent.Status, amount: int = 1) -> void:
	var status_inflicter_component: StatusInflicterComponent = get_node_or_null(StatusComponent.Status.keys()[status] + "Inflicter")
	if status_inflicter_component:
		status_inflicter_component.change_to_inflict_status_effect += StatusWeaponModifier.INFLICT_CHANCE
	else:
		status_inflicter_component = StatusInflicterComponent.new()
		status_inflicter_component.status = status
		status_inflicter_component.change_to_inflict_status_effect = StatusWeaponModifier.INFLICT_CHANCE * amount
		status_inflicter_component.name = StatusComponent.Status.keys()[status] + "Inflicter"
		add_child(status_inflicter_component)

	for i in amount:
		status_inflicter_added.emit(self, status)


func move(mouse_direction: Vector2) -> void:
	super(mouse_direction)
	if invert_scale_when_looking_left:
		if scale.y == 1 and mouse_direction.x < 0:
			scale.y = -1
		elif scale.y == -1 and mouse_direction.x > 0:
			scale.y = 1
