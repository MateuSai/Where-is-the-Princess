@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/enemies/goblin/goblin_idle_anim_f0.png")
class_name Enemy extends Character

const COIN_SCENE: PackedScene = preload("res://Items/Coin.tscn")

@onready var room: DungeonRoom = get_parent()
@onready var player: Player = get_tree().current_scene.get_node("Player")
@onready var path_timer: Timer = get_node("PathTimer")
@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")


func _ready() -> void:
	super()
	life_component.died.connect(Callable(get_parent(), "_on_enemy_killed"))


func spawn_loot() -> void:
	for i in 3:
		var coin: Coin = COIN_SCENE.instantiate()
		room.cleared.connect(coin.go_to_player)
		coin.position = global_position
		get_tree().current_scene.call_deferred("add_child", coin)


func chase() -> void:
	if not navigation_agent.is_target_reached():
		var vector_to_next_point: Vector2 = navigation_agent.get_next_path_position() - global_position
		mov_direction = vector_to_next_point

		if vector_to_next_point.x > 0 and sprite.flip_h:
			_on_change_dir()
		elif vector_to_next_point.x < 0 and not sprite.flip_h:
			_on_change_dir()


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
