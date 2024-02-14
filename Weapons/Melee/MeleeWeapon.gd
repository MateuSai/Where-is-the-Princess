@icon("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/weapon icons/Scimitar_icon.png")
class_name MeleeWeapon extends Weapon

const CUT_FLESH_SOUNDS: Array[AudioStream] = [preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Sword/MetalSlash1.wav"), preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Sword/MetalSlash2.wav"), preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Sword/MetalSlash3.wav")]
const IMPACT_FLESH_SOUNDS: Array[AudioStream] = [preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Hit(Impact)/HitGore1.wav"), preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Hit(Impact)/HitGore2.wav"), preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Hit(Impact)/HitGore3.wav"), preload("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Hit(Impact)/HitGore4.wav")]


var attack_num: int = 0:
	set(new_attack_num):
		attack_num = wrapi(new_attack_num, 0, data.num_normal_attacks)

@export var throw_speed: int = 200
var throw_dir: Vector2
var throw_rot_speed: float = 0

var piercing: int = 1
var bodies_pierced: int = 0

var spawn_weapon_shadow_timer: Timer

@onready var hitbox: WeaponHitbox = %Hitbox


func _ready() -> void:
	super()

	spawn_weapon_shadow_timer = Timer.new()
	spawn_weapon_shadow_timer.wait_time = 0.02
	spawn_weapon_shadow_timer.timeout.connect(_spawn_shadow_effect)
	add_child(spawn_weapon_shadow_timer)

	hitbox.collided_with_something.connect(func(_body: Node2D) -> void:
		_on_collided_with_something()
	)
	set_physics_process(false)

	hitbox.weapon = self
	hitbox.damage = data.damage
#	hitbox.exclude.push_back(Globals.player)

	match data.type:
		WeaponData.Type.HAMMER:
			hitbox.flesh_sounds = IMPACT_FLESH_SOUNDS
		_:
			hitbox.flesh_sounds = CUT_FLESH_SOUNDS


func _physics_process(delta: float) -> void:
	position += throw_dir * throw_speed * delta
	weapon_sprite.rotation += throw_rot_speed * delta


func _on_collided_with_something(col_mat: Hitbox.CollisionMaterial = Hitbox.CollisionMaterial.FLESH) -> void:
	# Double degrade amount if we collide with stone
	_decrease_weapon_condition(round(data.condition_cost_per_normal_attack * (col_mat+1)) as float)
	#stats.set_condition(stats.condition - round(condition_cost_per_normal_attack * (col_mat+1)))
#	match col_mat:
#		Hitbox.CollisionMaterial.FLESH:
#			var audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
#			audio.bus = "Sounds"
#			audio.position = global_position
#			audio.volume_db = -8
#			match type:
#				Type.HAMMER:
#					audio.stream = IMPACT_FLESH_SOUNDS[randi() % IMPACT_FLESH_SOUNDS.size()]
#				_:
#					audio.stream = CUT_FLESH_SOUNDS[randi() % CUT_FLESH_SOUNDS.size()]
#			get_tree().current_scene.add_child(audio)
#			audio.finished.connect(audio.queue_free)
#			audio.play()


func _pick_up() -> void:
	super()
	attack_num = 0


func _attack() -> void:
	#var dfdsf = get_animation_full_name("attack_2")
	#print(dfdsf.is_empty())
	if attack_num == 1 and get_animation_full_name("attack_2").is_empty():
		animation_player.play_backwards(get_animation_full_name("attack_1"))
	else:
		animation_player.play(get_animation_full_name("attack_" + str(attack_num + 1)))
	attack_num += 1
	used_normal_attack.emit()


func _charge() -> void:
	animation_player.play(get_animation_full_name("charge_" + str(attack_num + 1)))


func _strong_attack() -> void:
	animation_player.play(get_animation_full_name("strong_attack_" + str(attack_num + 1)))


func _active_ability(_animation_name: String = "active_ability") -> void:
	super("active_ability_" + str(attack_num + 1))
	if data.increase_num_normal_attacks_on_ability:
		attack_num += 1
	used_active_ability.emit()


func throw() -> void:
	throw_dir = (get_parent().get_parent() as Player).mouse_direction
	bodies_pierced = 0
	piercing = (get_parent().get_parent() as Player).throw_piercing
	if data.type == WeaponData.Type.SWORD:
		throw_rot_speed = 25 if attack_num == 0 else -25
	(get_parent() as PlayerWeapons).throw_weapon()
	(hitbox.get_node("CollisionShape2D") as CollisionShape2D).disabled = false
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
	@warning_ignore("unsafe_call_argument")
	var status_inflicter_component: StatusInflicterComponent = get_node_or_null(StatusComponent.Status.keys()[status] + "Inflicter")
	if status_inflicter_component:
		status_inflicter_component.change_to_inflict_status_effect += StatusWeaponModifier.INFLICT_CHANCE
	else:
		status_inflicter_component = StatusInflicterComponent.new()
		status_inflicter_component.status = status
		status_inflicter_component.change_to_inflict_status_effect = StatusWeaponModifier.INFLICT_CHANCE * amount
		status_inflicter_component.name = StatusComponent.Status.keys()[status] + "Inflicter"
		add_child(status_inflicter_component)

	for i: int in amount:
		status_inflicter_added.emit(self, status)


func move(mouse_direction: Vector2) -> void:
	super(mouse_direction)
	hitbox.knockback_direction = mouse_direction
	if data.invert_scale_when_looking_left:
		if scale.y == 1 and mouse_direction.x < 0:
			scale.y = -1
		elif scale.y == -1 and mouse_direction.x > 0:
			scale.y = 1


func destroy() -> void:
	hitbox.queue_free()
	super()


func set_damage(new_damage: int) -> void:
	super(new_damage)
	if animation_player and not animation_player.current_animation.begins_with("active_ability"):
		hitbox.damage = data.damage


func set_ability_damage(new_ability_damage: int) -> void:
	super(new_ability_damage)
	if animation_player and animation_player.current_animation.begins_with("active_ability"):
		hitbox.damage = data.ability_damage


func set_knockback(new_knockback: int) -> void:
	super(new_knockback)

	if animation_player and not animation_player.current_animation.begins_with("active_ability"):
			hitbox.knockback_force = data.knockback


func set_ability_knockback(new_ability_knockback: int) -> void:
	super(new_ability_knockback)

	if animation_player and animation_player.current_animation.begins_with("active_ability"):
		hitbox.knockback_force = data.ability_knockback


func _on_animation_started(anim_name: StringName) -> void:
	super(anim_name)

	#if anim_name != "RESET":
		#var a: Array[PhysicsBody2D] = (get_parent().get_parent() as Character).get_exclude_bodies()
		#hitbox.exclude = a

	if anim_name.begins_with("active_ability"):
		hitbox.damage = data.ability_damage
		hitbox.knockback_force = data.ability_knockback


func _on_animation_finished(anim_name: String) -> void:
	super(anim_name)

	if anim_name.begins_with("active_ability"):
		hitbox.damage = data.damage
		hitbox.knockback_force = data.knockback


func _start_shadow_effect() -> void:
	_spawn_shadow_effect()
	spawn_weapon_shadow_timer.start()


func _stop_shadow_effect() -> void:
	spawn_weapon_shadow_timer.stop()


func _spawn_shadow_effect() -> void:
	var shadow_sprite: ShadowSprite = ShadowSprite.new()
	shadow_sprite.modulate.a = 0.7
	shadow_sprite.scale = weapon_sprite.scale
	shadow_sprite.flip_h = weapon_sprite.flip_h
	shadow_sprite.flip_v = weapon_sprite.flip_v
	shadow_sprite.transform = weapon_sprite.global_transform
	#shadow_sprite.position = weapon_sprite.global_position
	#shadow_sprite.rotation = weapon_sprite.global_rotation
	shadow_sprite.offset = weapon_sprite.offset
	get_tree().current_scene.add_child(shadow_sprite)
	shadow_sprite.start(weapon_sprite.texture)


func _set_damage_dealer_id(new_id: String) -> void:
	super(new_id)
	hitbox.damage_dealer_id = damage_dealer_id


static func get_data(id: String) -> WeaponData:
	if DB.has(id):
		return MeleeWeaponData.from_dic(DB[id])
	else:
		return null
