@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/enemies/goblin/goblin_idle_anim_f0.png")
class_name Enemy extends Character

const SPAWN_EXPLOSION_SCENE: PackedScene = preload("res://Characters/Enemies/SpawnExplosion.tscn")
const COIN_SCENE: PackedScene = preload("res://items/Coin.tscn")
const SOUL_SCENE: PackedScene = preload("res://items/Soul.tscn")

@export var souls: int = 1

@export var is_boss: bool = false

@onready var room: DungeonRoom = get_parent()
@onready var player: Player = get_tree().current_scene.get_node("Player")
@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")
@onready var path_timer: Timer = get_node("PathTimer")
@onready var parallize_timer: Timer = $ParallizeTimer


func _ready() -> void:
	super()

	life_component.died.connect(func():
		get_parent()._on_enemy_killed(self)
	)

	parallize_timer.timeout.connect(func():
		#can_move = true
		state_machine.set_physics_process(true)
	)


func _load_csv_data(data: Dictionary) -> void:
	super(data)

	souls = data.souls
	is_boss = bool(data.is_boss)


func spawn_loot() -> void:
	for i in 3:
		var coin: Coin = COIN_SCENE.instantiate()
		room.cleared.connect(coin.go_to_player)
		coin.position = global_position
		get_tree().current_scene.call_deferred("add_child", coin)

	for i in souls:
		var soul: SoulItem = SOUL_SCENE.instantiate()
		room.cleared.connect(soul.go_to_player)
		soul.position = global_position
		get_tree().current_scene.call_deferred("add_child", soul)

	if is_boss:
		for i in 1:
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


func _on_change_dir() -> void:
	sprite.flip_h = !sprite.flip_h


func _on_PathTimer_timeout() -> void:
	if is_instance_valid(player):
		_get_path_to_player()
	else:
		path_timer.stop()
		mov_direction = Vector2.ZERO


func _get_path_to_player() -> void:
	navigation_agent.target_position = player.position


func _on_died() -> void:
	super()

	spawn_loot()

	await get_tree().create_timer(0.5, false).timeout

	var spawn_explosion: AnimatedSprite2D = SPAWN_EXPLOSION_SCENE.instantiate()
	spawn_explosion.position = global_position
	get_tree().current_scene.add_child(spawn_explosion)
	queue_free()


func parallize() -> void:
	if can_move:
		#can_move = false
		state_machine.set_physics_process(false)
		$AnimationPlayer.call_deferred("stop")
		parallize_timer.start()
