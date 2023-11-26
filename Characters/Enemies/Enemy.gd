@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/enemies/goblin/goblin_idle_anim_f0.png")
class_name Enemy extends Character

const SPAWN_EXPLOSION_SCENE: PackedScene = preload("res://Characters/Enemies/SpawnExplosion.tscn")
const COIN_SCENE: PackedScene = preload("res://items/Coin.tscn")
const SOUL_SCENE: PackedScene = preload("res://items/Soul.tscn")

const FLYING_ENEMIES_NAVIGATION_LAYER_BIT_VALUE: int = 2

var target: Character

@export var min_coins: int = 2
@export var max_coins: int = 3
@export var min_souls: int = 1
@export var max_souls: int = 1
@export var min_dark_souls: int = 0
@export var max_dark_souls: int = 0

@onready var room: DungeonRoom = get_parent()
@onready var player: Player = get_tree().current_scene.get_node("Player")
@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")
@onready var parallize_timer: Timer = $ParallizeTimer


func _ready() -> void:
	super()

	target = player

	assert(min_coins <= max_coins)
	assert(min_souls <= max_souls)
	assert(min_dark_souls <= max_dark_souls)

#	life_component.died.connect(func():
#		get_parent()._on_enemy_killed(self)
#	)

	parallize_timer.timeout.connect(func():
		can_move = true
		state_machine.set_physics_process(true)
	)


func _load_csv_data(data: Dictionary) -> void:
	super(data)

	var splitted_coins: PackedStringArray = str(data.coins).split("-")
	min_coins = int(splitted_coins[0])
	max_coins = int(splitted_coins[0 if splitted_coins.size() == 1 else 1])

	var splitted_souls: PackedStringArray = str(data.souls).split("-")
	min_souls = int(splitted_souls[0])
	max_souls = int(splitted_souls[0 if splitted_souls.size() == 1 else 1])

	var splitted_dark_souls: PackedStringArray = str(data.dark_souls).split("-")
	min_dark_souls = int(splitted_dark_souls[0])
	max_dark_souls = int(splitted_dark_souls[0 if splitted_dark_souls.size() == 1 else 1])


func spawn_loot() -> void:
	for i in randi_range(min_coins, max_coins):
		var coin: Coin = COIN_SCENE.instantiate()
		room.cleared.connect(coin.go_to_player)
		coin.position = global_position
		get_tree().current_scene.call_deferred("add_child", coin)

	for i in randi_range(min_souls, max_souls):
		var soul: SoulItem = SOUL_SCENE.instantiate()
		room.cleared.connect(soul.go_to_player)
		soul.position = global_position
		get_tree().current_scene.call_deferred("add_child", soul)

	for i in randi_range(min_dark_souls, max_dark_souls):
		var soul: DarkSoulOnFloor = load("res://items/DarkSoul.tscn").instantiate()
		room.cleared.connect(soul.go_to_player)
		soul.position = global_position
		get_tree().current_scene.call_deferred("add_child", soul)


func move_to_target() -> void:
	if not navigation_agent.is_target_reached():
		if can_move:
			var vector_to_next_point: Vector2 = navigation_agent.get_next_path_position() - global_position
			mov_direction = vector_to_next_point
			if vector_to_next_point.x > 0 and sprite.flip_h:
				_on_change_dir()
			elif vector_to_next_point.x < 0 and not sprite.flip_h:
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

	await get_tree().create_timer(0.5, false).timeout

	_on_died_0_5_seconds_later()


func _on_died_0_5_seconds_later() -> void:
	SavedData.add_kill(id)

	spawn_loot()

	var spawn_explosion: AnimatedSprite2D = SPAWN_EXPLOSION_SCENE.instantiate()
	spawn_explosion.position = global_position
	get_tree().current_scene.add_child(spawn_explosion)

	get_parent()._on_enemy_killed(self)

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
		if flying:
			add_resistance(Resistance.ACID)
			navigation_agent.navigation_layers |=  FLYING_ENEMIES_NAVIGATION_LAYER_BIT_VALUE
#			navigation_agent.navigation_layers = 2
			navigation_agent.set_navigation_map(room.tilemap.get_navigation_map(1))
		else:
			remove_resistance(Resistance.ACID)
#			navigation_agent.navigation_layers = 1
			navigation_agent.navigation_layers &= ~FLYING_ENEMIES_NAVIGATION_LAYER_BIT_VALUE
			navigation_agent.set_navigation_map(room.tilemap.get_navigation_map(0))
