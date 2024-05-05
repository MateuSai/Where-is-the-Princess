class_name Branch extends MeleeWeapon

var last_position: Vector2

const LEAF_SCENE: PackedScene = preload("res://Rooms/Furniture and Traps/leaf.tscn")
const NO_LEAFS_TEXTURE: Texture2D = preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/branch_without_leaves.png")

@onready var drop_leafs_position: Marker2D = $Node2D/WeaponSprite/DropLeafsPosition


func _ready() -> void:
	super()

	hitbox.collided_with_something.connect(_on_first_collide)


func _process(_delta: float) -> void:
	last_position = drop_leafs_position.global_position


func _on_first_collide(_body: Node2D) -> void:
	weapon_sprite.texture = NO_LEAFS_TEXTURE
	hitbox.collided_with_something.disconnect(_on_first_collide)

	for i: int in 2:
		await get_tree().process_frame
		if is_instance_valid(get_parent()):
			var leaf: Fragment = LEAF_SCENE.instantiate()
			leaf.position = drop_leafs_position.global_position
			get_tree().current_scene.add_child(leaf)
			leaf.throw((get_parent() as Weapons).character if (get_parent() as Weapons) != null else self, (drop_leafs_position.global_position - last_position).normalized().rotated(randf_range(-0.3, 0.3)))
