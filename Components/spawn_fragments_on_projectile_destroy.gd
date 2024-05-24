class_name SpawnFragmentsOnProjectileDestroy extends Node2D

@export var fragment_scene: PackedScene = load("res://effects/fragments/wood_fragment.tscn")

@export var min_fragments: int = 4
@export var max_fragments: int = 10

@onready var projectile: Projectile = get_parent()

func _ready() -> void:
	projectile.destroyed.connect(func() -> void:
		call_deferred("_spawn_fragments", projectile.direction)
	)

func _spawn_fragments(dir: Vector2) -> void:
	var amount: int = randi_range(min_fragments, max_fragments)
	#print("spawning %d fragments" % amount)
	for i: int in amount:
		#await get_tree().process_frame
		var fragment: Fragment = fragment_scene.instantiate()
		fragment.position = get_parent().global_position + position
		get_tree().current_scene.add_child(fragment)
		fragment.throw(self, dir.rotated(randf_range( - 1.0, 1.0)))