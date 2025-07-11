class_name RangedWeapon extends Weapon

var projectile_speed: int

signal projectiles_spawned(projectiles: Array[Projectile])

@onready var spawn_projectile_pos: Marker2D = %SpawnProjectilePos
@onready var shoot_sound: AudioStreamPlayer = $ShootSound

func _ready() -> void:
	super()

	if not data.shoot_sound_path.is_empty():
		shoot_sound.stream = load(data.shoot_sound_path)

## rot_offset is in radians. Returns an array containing the spawned projectiles
func _spawn_projectile(angle: float=0.0, amount: int=1, rotate_to_dir: bool = true) -> Array[Projectile]:
	if shoot_sound.stream:
		shoot_sound.play()

	var angle_step: float = angle / clamp(amount - 1, 1, INF)
	var initial_offset: float = -angle / 2

	var spawned_projectiles: Array[Projectile] = []

	for i: int in amount:
		var projectile: Projectile = (load(data.projectile_scene_path) as PackedScene).instantiate() if data.projectile_scene_path.ends_with(".tscn") else (load(data.projectile_scene_path) as GDScript).new()
		projectile.weapon = self
		projectile.damage_dealer_id = damage_dealer_id
		projectile.damage_dealer = damage_dealer
		if animation_player.current_animation == "active_ability":
			projectile.damage = data.ability_damage
			projectile.knockback_force = data.ability_knockback
		else:
			projectile.damage = data.damage
			projectile.knockback_force = data.knockback

		if damage_dealer is Player:
			projectile.damage *= damage_dealer.damage_multiplier

		if get_parent() is PlayerWeapons and stats.condition - data.condition_cost_per_normal_attack <= 0:
			projectile.damage += (get_parent() as PlayerWeapons).extra_damage_when_weapon_breaks

		for body: PhysicsBody2D in (get_parent().get_parent() as Character).get_exclude_bodies():
			projectile.exclude.push_back(body)
		# So the projectiles don't collide between them
		for other_projectile: Projectile in spawned_projectiles:
			other_projectile.exclude.push_back(projectile)
			projectile.exclude.push_back(other_projectile)
		spawned_projectiles.push_back(projectile)

		#Log.debug("Spawning projectile with speed " + str(projectile_speed))
		get_tree().current_scene.add_child(projectile)
		projectile.launch(spawn_projectile_pos.global_position, Vector2.RIGHT.rotated(rotation + initial_offset + i * angle_step), projectile_speed if damage_dealer is Player else projectile_speed * Settings.enemy_projectile_speed, rotate_to_dir)

		_decrease_weapon_condition(data.condition_cost_per_normal_attack)
#		stats.condition -= condition_cost_per_normal_attack

	projectiles_spawned.emit(spawned_projectiles)

	return spawned_projectiles

func _on_animation_started(anim_name: StringName) -> void:
	super(anim_name)

	if anim_name.begins_with("active_ability"):
		projectile_speed = data.ability_projectile_speed
	else:
		projectile_speed = data.normal_attack_projectile_speed

static func get_data(path: String) -> WeaponData:
	var id: String = get_id_from_path(path)
	if DB.has(id):
		return RangedWeaponData.from_dic(DB[id])
	else:
		var data_path: String = path.replace(path.get_file(), "data.tres")
		if FileAccess.file_exists(data_path):
			return load(data_path)

	return null
