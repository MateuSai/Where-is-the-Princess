class_name RangedWeapon extends Weapon

var projectile_speed: int

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


func _spawn_projectile() -> void:
	if shoot_sound.stream:
		shoot_sound.play()

	var projectile: Projectile = load(projectile_scene_path).instantiate()
	projectile.damage = damage
	projectile.exclude.push_back(Globals.player)
	get_tree().current_scene.add_child(projectile)
	projectile.launch(spawn_projectile_pos.global_position, Vector2.RIGHT.rotated(rotation), projectile_speed, true)


#func _on_animation_started(anim_name: StringName) -> void:
#	super(anim_name)
#
#	if anim_name.begins_with("")
