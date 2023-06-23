class_name DungeonRoom extends Node2D

@export var boss_room: bool = false

const SPAWN_EXPLOSION_SCENE: PackedScene = preload("res://Characters/Enemies/SpawnExplosion.tscn")

const ENEMY_SCENES: Dictionary = {
	"FLYING_CREATURE": preload("res://Characters/Enemies/Flying Creature/FlyingCreature.tscn"),
	"GOBLIN": preload("res://Characters/Enemies/Goblin/Goblin.tscn"), "SLIME_BOSS": preload("res://Characters/Enemies/Bosses/SlimeBoss.tscn")
}

const HORIZONTAL_DOOR: PackedScene = preload("res://Rooms/Furniture and Traps/HorizontalDoor.tscn")
const VERTICAL_DOOR: PackedScene = preload("res://Rooms/Furniture and Traps/VerticalDoor.tscn")

var num_enemies: int

var float_position: Vector2

enum EntryDirection {
	LEFT,
	UP,
	RIGHT,
	DOWN,
}
var used_entries: Array[Node] = []

signal room_cleared()

@onready var tilemap: TileMap = get_node("TileMap")
@onready var vector_to_center: Vector2 = tilemap.get_used_rect().position * Rooms.TILE_SIZE + tilemap.get_used_rect().size * Rooms.TILE_SIZE / 2
@onready var min_separation: float = (vector_to_center - Vector2(tilemap.get_used_rect().position * Rooms.TILE_SIZE)).length() * 2 * 1
@onready var entries: Array[Node] = [get_node("Entries/Left"), get_node("Entries/Up"), get_node("Entries/Right"), get_node("Entries/Down")]
@onready var door_container: Node2D = get_node("Doors")
@onready var enemy_positions_container: Node2D = get_node("EnemyPositions")


func _ready() -> void:
	num_enemies = enemy_positions_container.get_child_count()


func _draw() -> void:
	if get_parent().get_parent().debug:
		draw_circle(vector_to_center, (vector_to_center - Vector2(tilemap.get_used_rect().position * Rooms.TILE_SIZE)).length(), Color.RED)


func separation_steering(rooms: Array[DungeonRoom], delta: float) -> bool:
	var dir: Vector2 = Vector2.ZERO
	for room in rooms:
		if room == self:
			continue
		var vector_to_room: Vector2 = (room.position + room.vector_to_center) - (position + vector_to_center)
		if vector_to_room.length() < min_separation:
			dir += vector_to_room * (vector_to_room.length() - min_separation)

	float_position += dir.normalized() * 500 * randf_range(0.9, 1.1) * delta
	position = round(float_position/Rooms.TILE_SIZE) * Rooms.TILE_SIZE

	return dir == Vector2.ZERO


func has_entry(dir: EntryDirection) -> bool:
	var direction_entries: Array[Node] = entries[dir].get_children()
#	for entry in used_entries:
#		if direction_entries.has(entry):
#			direction_entries.erase(entry)

	return direction_entries.size() > 0


func get_entry_position(dir: EntryDirection) -> Vector2:
	return entries[dir].get_children()[0].global_position


func get_random_entry(dir: EntryDirection) -> Node:
	var direction_entries: Array[Node] = entries[dir].get_children()
#	for entry in used_entries:
#		if direction_entries.has(entry):
#			direction_entries.erase(entry)

	if direction_entries.is_empty():
		return null
	else:
		var rand_entry: Node = direction_entries[randi() % direction_entries.size()]
		used_entries.push_back(rand_entry)
		return rand_entry


func add_doors_and_walls(corridor_tilemap: TileMap) -> void:
	for dir in [EntryDirection.LEFT, EntryDirection.RIGHT]:
		for entry in entries[dir].get_children():
			if entry in used_entries:
				var vertical_door: Door = VERTICAL_DOOR.instantiate()
				vertical_door.position = floor(entry.position / 16) * 16
				if dir == EntryDirection.LEFT:
					vertical_door.position += Vector2(18, 6)
				else:
					vertical_door.position += Vector2(-2, 4)
					vertical_door.scale.x = -1
				door_container.add_child(vertical_door)
			else:
				var tile_positions: Array[Vector2i] = []
				tile_positions.push_back(tilemap.local_to_map(entry.position + entry.get_child(0).position))
				tile_positions.push_back(tilemap.local_to_map(entry.position + entry.get_child(1).position))
				tilemap.erase_cell(3, tile_positions[1])
				if dir == EntryDirection.LEFT:
					tilemap.set_cell(0, tile_positions[0] + Vector2i.UP * 2, Rooms.ATLAS_ID, Rooms.LEFT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0] + Vector2i.UP, Rooms.ATLAS_ID, Rooms.LEFT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0], Rooms.ATLAS_ID, Rooms.LEFT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[1], Rooms.ATLAS_ID, Rooms.LEFT_WALL_COOR)
				else:
					tilemap.set_cell(0, tile_positions[0] + Vector2i.UP * 2, Rooms.ATLAS_ID, Rooms.RIGHT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0] + Vector2i.UP, Rooms.ATLAS_ID, Rooms.RIGHT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0], Rooms.ATLAS_ID, Rooms.RIGHT_WALL_COOR)
					tilemap.set_cell(0, tile_positions[1], Rooms.ATLAS_ID, Rooms.RIGHT_WALL_COOR)
	for dir in [EntryDirection.UP, EntryDirection.DOWN]:
		for entry in entries[dir].get_children():
			if entry in used_entries:
				var horizontal_door: Door = HORIZONTAL_DOOR.instantiate()
				horizontal_door.position = floor(entry.position / 16) * 16 + Vector2(Rooms.TILE_SIZE, Rooms.TILE_SIZE)
				door_container.add_child(horizontal_door)
				if dir == EntryDirection.UP:
					corridor_tilemap.erase_cell(1, corridor_tilemap.local_to_map(entry.global_position) + Vector2i.UP)
					corridor_tilemap.erase_cell(1, corridor_tilemap.local_to_map(entry.global_position) + Vector2i.UP + Vector2i.RIGHT)
			else:
				var tile_positions: Array[Vector2i] = []
				tile_positions.push_back(tilemap.local_to_map(entry.position + entry.get_child(0).position))
				tile_positions.push_back(tilemap.local_to_map(entry.position + entry.get_child(1).position))
				if dir == EntryDirection.UP:
					tilemap.set_cell(0, tile_positions[0] + Vector2i.LEFT, Rooms.ATLAS_ID, Rooms.UPPER_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0], Rooms.ATLAS_ID, Rooms.UPPER_WALL_COOR)
					tilemap.set_cell(0, tile_positions[1], Rooms.ATLAS_ID, Rooms.UPPER_WALL_COOR)
					tilemap.set_cell(0, tile_positions[1] + Vector2i.RIGHT, Rooms.ATLAS_ID, Rooms.UPPER_WALL_COOR)
					tilemap.set_cell(0, tile_positions[0] + Vector2i.DOWN, Rooms.ATLAS_ID, Rooms.FULL_WALL_COORDS[randi() % Rooms.FULL_WALL_COORDS.size()])
					tilemap.set_cell(0, tile_positions[1] + Vector2i.DOWN, Rooms.ATLAS_ID, Rooms.FULL_WALL_COORDS[randi() % Rooms.FULL_WALL_COORDS.size()])
				else:
					tilemap.set_cell(1, tile_positions[0] + Vector2i.LEFT, Rooms.ATLAS_ID, Rooms.BOTTOM_WALL_COOR)
					tilemap.set_cell(1, tile_positions[0], Rooms.ATLAS_ID, Rooms.BOTTOM_WALL_COOR)
					tilemap.set_cell(1, tile_positions[1], Rooms.ATLAS_ID, Rooms.BOTTOM_WALL_COOR)
					tilemap.set_cell(1, tile_positions[1] + Vector2i.RIGHT, Rooms.ATLAS_ID, Rooms.BOTTOM_WALL_COOR)

	for door in door_container.get_children():
		door.player_entered_room.connect(_on_player_entered_room)


func _on_enemy_killed() -> void:
	num_enemies -= 1
	if num_enemies == 0:
		emit_signal("room_cleared")
		_open_doors()


func _open_doors() -> void:
	for door in door_container.get_children():
		door.open()


func _close_entrance() -> void:
	for door in door_container.get_children():
		door.close()
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



func _on_player_entered_room() -> void:
	if num_enemies > 0:
		_close_entrance()
		_spawn_enemies()
	else:
		pass
		#_close_entrance()
		#_open_doors()
