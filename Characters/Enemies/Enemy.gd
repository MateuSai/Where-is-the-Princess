@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/enemies/goblin/goblin_idle_anim_f0.png")
class_name Enemy extends Character

const ENEMIES_FOLDER_PATH: String = "res://Characters/Enemies/"

const SPAWN_EXPLOSION_SCENE: PackedScene = preload ("res://Characters/Enemies/SpawnExplosion.tscn")
const COIN_SCENE: PackedScene = preload ("res://items/Coin.tscn")
const SOUL_SCENE: PackedScene = preload ("res://items/Soul.tscn")

const BIG_ACID_PUDDLE_SCENE: PackedScene = preload ("res://Characters/Enemies/big_slime/big_acid_puddle.tscn")
const MEDIUM_ACID_PUDDLE_SCENE: PackedScene = preload ("res://Characters/Enemies/medium_slime/acid_puddle.tscn")
const SMALL_ACID_PUDDLE_SCENE: PackedScene = preload ("res://Characters/Enemies/small_slime/small_acid_puddle.tscn")

const FLYING_ENEMIES_NAVIGATION_LAYER_BIT_VALUE: int = 2

var enemy_data: EnemyData

var get_dir: Callable = func() -> Vector2:
	return navigation_agent.get_next_path_position() - global_position

#@export var unlock_weapon_on_kills: UnlockWeaponOnKills = null

@onready var room: DungeonRoom = get_parent()
@onready var player: Player = get_tree().current_scene.get_node("Player")
@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")
@onready var parallize_timer: Timer = $ParallizeTimer
@onready var enemy_weapons: EnemyWeapons = get_node_or_null("EnemyWeapons")

func _ready() -> void:
	super()

	target = player

	assert(data.min_coins <= data.max_coins)
	assert(data.min_souls <= data.max_souls)
	assert(data.min_dark_souls <= data.max_dark_souls)

#	life_component.died.connect(func():
#		get_parent()._on_enemy_killed(self)
#	)

	parallize_timer.timeout.connect(func() -> void:
		can_move=true
		state_machine.set_physics_process(true)
	)

func _load_data() -> void:
	data = Enemy.get_data(id)
	enemy_data = data

func spawn_loot() -> void:
	var coin_amount: int = randi_range(enemy_data.min_coins, enemy_data.max_coins)
	coin_amount = ceil(coin_amount * Globals.global_stats.enemy_coin_multiplier)
	for i: int in coin_amount:
		var coin: Coin = COIN_SCENE.instantiate()
		room.cleared.connect(coin.go_to_player)
		coin.position = global_position
		get_tree().current_scene.call_deferred("add_child", coin)

	for i: int in randi_range(enemy_data.min_souls, enemy_data.max_souls):
		var soul: SoulItem = SOUL_SCENE.instantiate()
		room.cleared.connect(soul.go_to_player)
		soul.position = global_position
		get_tree().current_scene.call_deferred("add_child", soul)

	for i: int in randi_range(enemy_data.min_dark_souls, enemy_data.max_dark_souls):
		var soul: DarkSoulOnFloor = (load("res://items/DarkSoul.tscn") as PackedScene).instantiate()
		room.cleared.connect(soul.go_to_player)
		soul.position = global_position
		get_tree().current_scene.call_deferred("add_child", soul)

	# Armor shard
	if randf() <= enemy_data.armor_shard_prob:
		var item_on_floor: ItemOnFloor = preload ("res://items/item_on_floor.tscn").instantiate()
		var armor_shard: ArmorShard = ArmorShard.new()
		room.add_item_on_floor(item_on_floor, position + Vector2(randf_range( - 8, 8), randf_range( - 8, 8)))
		item_on_floor.initialize(armor_shard)
		item_on_floor.enable_pick_up()

	# Food
	if randf() <= data.food_prob:
		var item_on_floor: ItemOnFloor = preload ("res://items/item_on_floor.tscn").instantiate()
		var food: Food = Food.new()
		room.add_item_on_floor(item_on_floor, position + Vector2(randf_range( - 8, 8), randf_range( - 8, 8)))
		item_on_floor.initialize(food)
		item_on_floor.enable_pick_up()

	# Whetstone
	if randf() <= data.whetstone_prob:
		var item_on_floor: ItemOnFloor = preload ("res://items/item_on_floor.tscn").instantiate()
		var whetstone: Whetstone = Whetstone.new()
		room.add_item_on_floor(item_on_floor, position + Vector2(randf_range( - 8, 8), randf_range( - 8, 8)))
		item_on_floor.initialize(whetstone)
		item_on_floor.enable_pick_up()

func move_to_target() -> void:
	if not navigation_agent.is_target_reached():
		if can_move:
			#var vector_to_next_point: Vector2 = navigation_agent.get_next_path_position() - global_position
			mov_direction = get_dir.call()
			if mov_direction.x > 0 and sprite.flip_h:
				_on_change_dir()
			elif mov_direction.x < 0 and not sprite.flip_h:
				_on_change_dir()
		else:
			mov_direction = Vector2.ZERO

#func target_random_near_position() -> void:
#	var max_iterations: int = 10
#	var iterations: int = 0
#
#	while iterations < max_iterations:
#		navigation_agent.target_position = global_position + Vector2(randf_range(-64, 64), randf_range(-64, 64))
#		if navigation_agent.is_target_reachable():
#			return
#
#		iterations += 1
#
#	push_error("To many iterations to determine new close random position")

#func circle_player() -> void:
#	if navigation_agent.is_target_reached():
#		navigation_agent.target_position = _get_closer_position_to_circle_player()
#	elif not navigation_agent.is_target_reachable():
#		rot_around_character_dir *= -1
#		navigation_agent.target_position = _get_closer_position_to_circle_player()
#
#
#func _get_closer_position_to_circle_player() -> Vector2:
#	return global_position + (player.position - global_position).normalized().rotated(rot_around_character_dir * PI/2) * 8

func _on_change_dir() -> void:
	sprite.flip_h = !sprite.flip_h

func _on_died() -> void:
	super()

	if enemy_weapons:
		enemy_weapons.free()

	if life_component.last_weapon != null and life_component.last_damage_dealer_id == "player":
		SavedData.statistics.add_weapon_kill(life_component.last_weapon.weapon_id)

	if life_component.last_damage_dealer_id == "crocodile":
		SavedData.complete_achievement(Achievements.Achievement.crocodile_help)

	await get_tree().create_timer(0.5, false).timeout

	_on_died_0_5_seconds_later()

func _on_died_0_5_seconds_later() -> void:
	SavedData.add_enemy_times_killed(id)

	spawn_loot()
	if Globals.global_stats.enemy_dead_acid_explosion:
		_spawn_acid_explosion()

	var spawn_explosion: AnimatedSprite2D = SPAWN_EXPLOSION_SCENE.instantiate()
	spawn_explosion.position = global_position
	get_tree().current_scene.add_child(spawn_explosion)

	room._on_enemy_killed(self)

	queue_free()

func parallize() -> void:
	if can_move:
		can_move = false
		state_machine.set_physics_process(false)
		$AnimationPlayer.call_deferred("stop")
		parallize_timer.start()

func set_flying(new_value: bool) -> void:
	super(new_value)

	if navigation_agent:
		if data.flying:
			add_resistance(Resistance.ACID)
			#navigation_agent.navigation_layers |=  FLYING_ENEMIES_NAVIGATION_LAYER_BIT_VALUE
#			navigation_agent.navigation_layers = 2
			navigation_agent.set_navigation_map(room.navigation_map_flying_units)
			if not room.navigation_updated.is_connected(_on_flying_enemy_navigation_updated):
				room.navigation_updated.connect(_on_flying_enemy_navigation_updated)
		else:
			if room.navigation_updated.is_connected(_on_flying_enemy_navigation_updated):
				room.navigation_updated.disconnect(_on_flying_enemy_navigation_updated)

			if not has_resistance(Resistance.ACID, true):
				remove_resistance(Resistance.ACID)
#			navigation_agent.navigation_layers = 1
			#navigation_agent.navigation_layers &= ~FLYING_ENEMIES_NAVIGATION_LAYER_BIT_VALUE
			navigation_agent.set_navigation_map(room.get_navigation_map())

func _on_flying_enemy_navigation_updated() -> void:
	navigation_agent.set_navigation_map(room.navigation_map_flying_units)

func _get_tile_type() -> String:
	return room.tilemap.get_cell_tile_data(0, room.tilemap.local_to_map(position)).get_custom_data_by_layer_id(0)

func _get_acid_puddle_scene() -> PackedScene:
	if data.mass < 12:
		return SMALL_ACID_PUDDLE_SCENE
	elif data.mass < 70:
		return MEDIUM_ACID_PUDDLE_SCENE
	else:
		return BIG_ACID_PUDDLE_SCENE

func _spawn_acid_explosion() -> void:
	for i: int in randi_range(3, 6):
		var acid_puddle: AcidPuddle = _get_acid_puddle_scene().instantiate()
		room.add_child(acid_puddle)
		acid_puddle.position = position + Vector2(randf_range( - 8, 8), randf_range( - 8, 8))

@warning_ignore("shadowed_variable")
static func get_data(id: String) -> EnemyData:
	if DB.has(id):
		return EnemyData.from_dic(DB[id])
	elif Globals.ENEMIES.has(id):
		return Globals.ENEMIES[id].data
	else:
		return null

static func get_path_and_info(enemy_folder: String, enemies_folder: DirAccess=DirAccess.open(Enemy.ENEMIES_FOLDER_PATH)) -> Dictionary:
	assert(enemies_folder != null)

	if not enemies_folder.file_exists(enemy_folder + "/" + enemy_folder + (".tscn" if OS.has_feature("editor") else ".tscn.remap")):
		push_error(enemy_folder + "/" + enemy_folder + ".tscn" + " not found on " + ENEMIES_FOLDER_PATH)
		return {}
	var info: Dictionary = {}
	if FileAccess.file_exists(ENEMIES_FOLDER_PATH + enemy_folder + "/" + "unlock_weapon_on_kills.tres"):
		info["unlock_weapon_on_kills"] = load(ENEMIES_FOLDER_PATH + enemy_folder + "/" + "unlock_weapon_on_kills.tres")
	if FileAccess.file_exists(ENEMIES_FOLDER_PATH + enemy_folder + "/" + "data.tres"):
		info["data"] = load(ENEMIES_FOLDER_PATH + enemy_folder + "/" + "data.tres")
	return {
		"path": ENEMIES_FOLDER_PATH + enemy_folder + "/" + enemy_folder + ".tscn",
		"info": info,
	}
