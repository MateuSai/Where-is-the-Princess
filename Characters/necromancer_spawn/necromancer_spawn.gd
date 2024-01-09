class_name NecromancerSpawn extends Sprite2D

signal enemy_spawned(enemy: Enemy)

@onready var room: DungeonRoom = get_parent()


func _spawn_skeleton() -> void:
	var rand: int = randi() % 100
	var enemy: Enemy
	if rand < 70:
		enemy = Globals.get_enemy_scene("dagger_skelebro").instantiate()
	elif rand < 85:
		enemy = Globals.get_enemy_scene("skelebro").instantiate()
	else:
		enemy = Globals.get_enemy_scene("archeleton").instantiate()

	enemy.position = position
	room.add_enemy(enemy)
	enemy_spawned.emit(enemy)
