extends Node2D
class_name DungeonRoom

@export var boss_room: bool = false

const SPAWN_EXPLOSION_SCENE: PackedScene = preload("res://Characters/Enemies/SpawnExplosion.tscn")

const ENEMY_SCENES: Dictionary = {
	"FLYING_CREATURE": preload("res://Characters/Enemies/Flying Creature/FlyingCreature.tscn"),
	"GOBLIN": preload("res://Characters/Enemies/Goblin/Goblin.tscn"), "SLIME_BOSS": preload("res://Characters/Enemies/Bosses/SlimeBoss.tscn")
}

var num_enemies: int

var float_position: Vector2

enum EntryDirection {
	LEFT,
	UP,
	RIGHT,
	DOWN,
}
var used_entries: Array[Node] = []

@onready var tilemap: TileMap = get_node("TileMap")
@onready var vector_to_center: Vector2 = tilemap.get_used_rect().size * Rooms.TILE_SIZE / 2
@onready var min_separation: float = vector_to_center.length() * 2 * 1
@onready var entries: Array[Node] = [get_node("Entries/Left"), get_node("Entries/Up"), get_node("Entries/Right"), get_node("Entries/Down")]
@onready var door_container: Node2D = get_node("Doors")
@onready var enemy_positions_container: Node2D = get_node("EnemyPositions")
@onready var player_detector: Area2D = get_node("PlayerDetector")


func _ready() -> void:
	num_enemies = enemy_positions_container.get_child_count()


func separation_steering(rooms: Array[DungeonRoom], delta: float) -> bool:
	var dir: Vector2 = Vector2.ZERO
	for room in rooms:
		if room == self:
			continue
		var vector_to_room: Vector2 = (room.position + room.vector_to_center) - (position + vector_to_center)
		if vector_to_room.length() < min_separation:
			dir += vector_to_room * (vector_to_room.length() - min_separation)

	float_position += dir.normalized() * 200 * delta
	position = round(float_position/Rooms.TILE_SIZE) * Rooms.TILE_SIZE

	return dir == Vector2.ZERO


func get_random_entry(dir: EntryDirection) -> Node:
	var direction_entries: Array[Node] = entries[dir].get_children()
	for entry in used_entries:
		if direction_entries.has(entry):
			direction_entries.erase(entry)

	if direction_entries.is_empty():
		return null
	else:
		var rand_entry: Node = direction_entries[randi() % direction_entries.size()]
		used_entries.push_back(rand_entry)
		return rand_entry


func _on_enemy_killed() -> void:
	num_enemies -= 1
	if num_enemies == 0:
		_open_doors()


func _open_doors() -> void:
	for door in door_container.get_children():
		door.open()


func _close_entrance() -> void:
	pass
#	for entry_position in entrance.get_children():
#		tilemap.set_cell(1, tilemap.local_to_map(entry_position.position), 1, Vector2i.ZERO)
#		tilemap.set_cell(1, tilemap.local_to_map(entry_position.position) + Vector2i.DOWN, 2, Vector2i.ZERO)


func _spawn_enemies() -> void:
	for enemy_position in enemy_positions_container.get_children():
		var enemy: CharacterBody2D
		if boss_room:
			enemy = ENEMY_SCENES.SLIME_BOSS.instantiate()
			num_enemies = 15
		else:
			if randi() % 2 == 0:
				enemy = ENEMY_SCENES.FLYING_CREATURE.instantiate()
			else:
				enemy = ENEMY_SCENES.GOBLIN.instantiate()
		enemy.position = enemy_position.position
		call_deferred("add_child", enemy)

		var spawn_explosion: AnimatedSprite2D = SPAWN_EXPLOSION_SCENE.instantiate()
		spawn_explosion.position = enemy_position.position
		call_deferred("add_child", spawn_explosion)



func _on_PlayerDetector_body_entered(_body: CharacterBody2D) -> void:
	player_detector.queue_free()
	if num_enemies > 0:
		_close_entrance()
		_spawn_enemies()
	else:
		_close_entrance()
		_open_doors()
