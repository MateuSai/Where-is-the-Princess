class_name RangedWeapon extends Weapon

var projectile_speed: int
var normal_attack_projectile_speed: int = 200
var ability_projectile_speed: int = 300

# Path to projectile scene
@export_file("*.tscn") var projectile_scene_path: String
@export_file var shoot_sound_path: String

@onready var spawn_projectile_pos: Marker2D = %SpawnProjectilePos
@onready var shoot_sound: AudioStreamPlayer = $ShootSound


func _load_csv_data(data: Dictionary) -> void:
	super(data)

	projectile_scene_path = data.projectile_scene_path
	shoot_sound_path = data.shoot_sound_path
	if not shoot_sound_path.is_empty():
		shoot_sound.stream = load(shoot_sound_path)


## rot_offser is in radians. Returns an array containing the spawned projectiles
func _spawn_projectile(angle: float = 0.0, amount: int = 1) -> Array[Projectile]:
	if shoot_sound.stream:
		shoot_sound.play()

	var angle_step: float = angle / clamp(amount - 1, 1, INF)
	var initial_offset: float = -angle / 2

	var spawned_projectiles: Array[Projectile] = []

	for i: int in amount:
		var projectile: Projectile = (load(projectile_scene_path) as PackedScene).instantiate() if projectile_scene_path.ends_with(".tscn") else (load(projectile_scene_path) as GDScript).new()
		projectile.weapon = self
		if animation_player.current_animation == "active_ability":
			projectile.damage = ability_damage
			projectile.knockback_force = ability_knockback
		else:
			projectile.damage = damage
			projectile.knockback_force = knockback

		for body: PhysicsBody2D in (get_parent().get_parent() as Character).get_exclude_bodies():
			projectile.exclude.push_back(body)
		# So the projectiles don't collide between them
		for other_projectile: Projectile in spawned_projectiles:
			other_projectile.exclude.push_back(projectile)
			projectile.exclude.push_back(other_projectile)
		spawned_projectiles.push_back(projectile)

		get_tree().current_scene.add_child(projectile)
		projectile.launch(spawn_projectile_pos.global_position, Vector2.RIGHT.rotated(rotation + initial_offset + i * angle_step), projectile_speed, true)

		_decrease_weapon_condition(condition_cost_per_normal_attack)
#		stats.condition -= condition_cost_per_normal_attack

	return spawned_projectiles


func _on_animation_started(anim_name: StringName) -> void:
	super(anim_name)

	if anim_name.begins_with("active_ability"):
		projectile_speed = ability_projectile_speed
	else:
		projectile_speed = normal_attack_projectile_speed
