class_name RangedWeapon extends Weapon

# Path to projectile scene
@export_file("tscn") var projectile_scene_path: String

@onready var spawn_projectile_pos: Marker2D = %SpawnProjectilePos


func _load_csv_data(data: Dictionary) -> void:
	super(data)

	projectile_scene_path = data.projectile_scene_path


func _spawn_projectile() -> void:
	var projectile: Projectile = load(projectile_scene_path).instantiate()
	projectile.damage = damage
	projectile.exclude.push_back(Globals.player)
	get_tree().current_scene.add_child(projectile)
	projectile.launch(spawn_projectile_pos.global_position, Vector2.RIGHT.rotated(rotation), 150, true)
