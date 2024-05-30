extends DungeonRoom

var spawn_branch_position: Vector2

@onready var branch: Branch = get_node("Weapons/Branch")

func _ready() -> void:
	super()

	spawn_branch_position = branch.position

	branch.hitbox.collided_with_something.connect(_on_branch_collided_with_something, CONNECT_ONE_SHOT)

func _on_branch_collided_with_something(_body: Node2D) -> void:
	Log.debug("_on_branch_collided_with_something")

	var spawn_explosion: AnimatedSprite2D = DungeonRoom.SPAWN_EXPLOSION_SCENE.instantiate()
	spawn_explosion.position = branch.weapon_sprite.global_position + branch.weapon_sprite.offset.rotated(branch.global_rotation) - position
	call_deferred("add_child", spawn_explosion)

	branch.queue_free()

	branch = load("res://Weapons/Melee/branch/branch.tscn").instantiate()
	call_deferred("add_weapon_on_floor", branch, spawn_branch_position)
	await get_tree().process_frame
	branch.get_node("%Hitbox").collided_with_something.connect(_on_branch_collided_with_something, CONNECT_ONE_SHOT)

	var spawn_explosion_2: AnimatedSprite2D = DungeonRoom.SPAWN_EXPLOSION_SCENE.instantiate()
	spawn_explosion_2.position = branch.weapon_sprite.global_position + branch.weapon_sprite.offset.rotated(branch.get_node("Node2D").rotation) - position
	call_deferred("add_child", spawn_explosion_2)
