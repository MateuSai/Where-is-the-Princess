class_name TutorialForestThrowPracticeRoom extends DungeonRoom

var spawn_branch_position: Vector2

var room_cleared: bool = false

@onready var branch: Branch = get_node("Weapons/Branch")

func _ready() -> void:
	super()

	spawn_branch_position = branch.position

	branch.hitbox.collided_with_something.connect(_on_branch_collided_with_something, CONNECT_ONE_SHOT)

	#await rooms.game.player_added

	player_entered.connect(func() -> void:
		_close_entrance()
		Globals.player.weapons.weapon_switched.connect(_on_weapon_switched)
	, CONNECT_ONE_SHOT)

func _on_branch_collided_with_something(_body: Node2D) -> void:
	#Log.debug("_on_branch_collided_with_something")
	if room_cleared:
		return # If the room is arleady cleared we don't want to spawna another branch anymore

	var spawn_explosion: AnimatedSprite2D = DungeonRoom.SPAWN_EXPLOSION_SCENE.instantiate()
	spawn_explosion.position = branch.weapon_sprite.global_position + branch.weapon_sprite.offset.rotated(branch.global_rotation) - position
	add_child.call_deferred(spawn_explosion)

	branch.queue_free()

	branch = load("res://Weapons/Melee/branch/branch.tscn").instantiate()
	add_weapon_on_floor.call_deferred(branch, spawn_branch_position)
	await get_tree().process_frame
	if not room_cleared:
		branch.get_node("%Hitbox").collided_with_something.connect(_on_branch_collided_with_something, CONNECT_ONE_SHOT)

	var spawn_explosion_2: AnimatedSprite2D = DungeonRoom.SPAWN_EXPLOSION_SCENE.instantiate()
	spawn_explosion_2.position = branch.weapon_sprite.global_position + branch.weapon_sprite.offset.rotated(branch.get_node("Node2D").rotation) - position
	add_child.call_deferred(spawn_explosion_2)

func _on_weapon_switched(_previous_index: int, new_index: int) -> void:
	if Globals.player.weapons.get_child(new_index) is Branch:
		Globals.player.weapons.weapon_switched.disconnect(_on_weapon_switched)
		Globals.player.weapons.block_throw = false
		Globals.character_received_damage.connect(func(_character: Node2D, _damage_dealer: Node) -> void:
			_open_doors()
			room_cleared=true
		, CONNECT_ONE_SHOT)
