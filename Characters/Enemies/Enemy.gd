@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/enemies/goblin/goblin_idle_anim_f0.png")
class_name Enemy extends Character

const SPAWN_EXPLOSION_SCENE: PackedScene = preload("res://Characters/Enemies/SpawnExplosion.tscn")
const COIN_SCENE: PackedScene = preload("res://items/Coin.tscn")
const SOUL_SCENE: PackedScene = preload("res://items/Soul.tscn")

const FLYING_ENEMIES_NAVIGATION_LAYER_BIT_VALUE: int = 2

var target: Character

var enemy_data: EnemyData

var get_dir: Callable = func() -> Vector2:
	return navigation_agent.get_next_path_position() - global_position

#@export var unlock_weapon_on_kills: UnlockWeaponOnKills = null

@onready var room: DungeonRoom = get_parent()
@onready var player: Player = get_tree().current_scene.get_node("Player")
@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")
@onready var parallize_timer: Timer = $ParallizeTimer


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
		can_move = true
		state_machine.set_physics_process(true)
	)


func _load_data() -> void:
	data = Enemy.get_data(id)
	enemy_data = data


func spawn_loot() -> void:
	for i: int in randi_range(enemy_data.min_coins, enemy_data.max_coins):
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
		var item_on_floor: ItemOnFloor = preload("res://items/item_on_floor.tscn").instantiate()
		var armor_shard: ArmorShard = ArmorShard.new()
		room.add_item_on_floor(item_on_floor, position + Vector2(randf_range(-8, 8), randf_range(-8, 8)))
		item_on_floor.initialize(armor_shard)
		item_on_floor.enable_pick_up()

	# Food
	if randf() <= data.food_prob:
		var item_on_floor: ItemOnFloor = preload("res://items/item_on_floor.tscn").instantiate()
		var food: Food = Food.new()
		room.add_item_on_floor(item_on_floor, position + Vector2(randf_range(-8, 8), randf_range(-8, 8)))
		item_on_floor.initialize(food)
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

	if life_component.last_weapon != null and life_component.last_damage_dealer_id == "player":
		SavedData.statistics.add_weapon_kill(life_component.last_weapon.weapon_id)

	await get_tree().create_timer(0.5, false).timeout

	_on_died_0_5_seconds_later()


func _on_died_0_5_seconds_later() -> void:
	SavedData.add_enemy_times_killed(id)

	spawn_loot()

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


@warning_ignore("shadowed_variable")
static func get_data(id: String) -> EnemyData:
	if DB.has(id):
		return EnemyData.from_dic(DB[id])
	elif Globals.ENEMIES.has(id):
		return Globals.ENEMIES[id].data
	else:
		return null
