class_name Crate extends StaticBody2D

const EXPLOSION_SCENE: PackedScene = preload("res://Characters/Enemies/SpawnExplosion.tscn")

@onready var room: DungeonRoom = get_parent()

@onready var sprite: Sprite2D = $Sprite2D
@onready var life_component: LifeComponent = $LifeComponent


func _ready() -> void:
	life_component.died.connect(func() -> void:
		sprite.frame = (randi() % 3) + 1
		var explosion: AnimatedSprite2D = EXPLOSION_SCENE.instantiate()
		explosion.position = global_position
		get_tree().current_scene.add_child(explosion)
		# Now the flying units will be able to pass over the box
		collision_layer = 16 # Low object
		remove_from_group(DungeonRoom.FLYING_UNITS_NAVIGATION_GROUP)
		room.update_navigation()
	)
