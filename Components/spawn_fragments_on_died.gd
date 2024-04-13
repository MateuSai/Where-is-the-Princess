class_name SpawnFragmentsOnDied extends Node2D

@export var min_fragments: int = 4
@export var max_fragments: int = 10

var room: DungeonRoom
@onready var life_component: LifeComponent = get_node("../LifeComponent")

func _ready() -> void:
	var current_parent: Node = get_parent()
	var max_iter: int = 8
	var i: int = 0
	while room == null:
		if current_parent is DungeonRoom:
			room = current_parent
			break

		current_parent = current_parent.get_parent()
		i += 1
		if i >= max_iter:
			push_error("Could not find room parent")
			break

	life_component.damage_taken.connect(func(_dam: int, dir: Vector2, _force: int) -> void:
		#shake_component.shake(sprite)
		if life_component.hp == 0:
			_spawn_fragments(dir)
	)

func _spawn_fragments(dir: Vector2) -> void:
	var wood_fragment_scene: PackedScene = load("res://Rooms/Furniture and Traps/wood_fragment.tscn")

	var amount: int = randi_range(min_fragments, max_fragments)
	for i: int in amount:
		await get_tree().process_frame
		var wood_fragment: Fragment = wood_fragment_scene.instantiate()
		wood_fragment.position = get_parent().position + position
		room.add_child(wood_fragment)
		wood_fragment.throw(self, dir.rotated(randf_range( - 1.0, 1.0)))