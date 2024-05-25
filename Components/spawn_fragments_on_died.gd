class_name SpawnFragmentsOnDied extends Node2D

@export var fragment_scene: PackedScene = load("res://effects/fragments/wood_fragment.tscn")

@export var min_fragments: int = 4
@export var max_fragments: int = 10

#var room: DungeonRoom
@onready var life_component: LifeComponent = get_node("../LifeComponent")

func _ready() -> void:
	#var current_parent: Node = get_parent()
	#var max_iter: int = 8
	#var i: int = 0
	#while room == null:
	#	if current_parent is DungeonRoom:
	#		room = current_parent
	#		break

	#	current_parent = current_parent.get_parent()
	#	i += 1
	#	if i >= max_iter:
	#		push_error("Could not find room parent")
	#		break

	life_component.damage_taken.connect(func(_dam: int, dir: Vector2, _force: int) -> void:
		#shake_component.shake(sprite)
		if life_component.hp == 0:
			call_deferred("_spawn_fragments", dir)
	)

func _spawn_fragments(dir: Vector2) -> void:
	var amount: int = randi_range(min_fragments, max_fragments)
	#print("spawning %d fragments" % amount)
	for i: int in amount:
		#await get_tree().process_frame
		var fragment: Fragment = fragment_scene.instantiate()
		fragment.position = get_parent().global_position + position
		get_tree().current_scene.add_child(fragment)
		var fragment_dir: Vector2 = (dir.rotated(randf_range( - 1.0, 1.0))) if dir.is_zero_approx() else Vector2.RIGHT.rotated(randf_range(0.0, 2 * PI))
		fragment.throw(self, fragment_dir)