class_name ExplosionOndied extends Node

const EXPLOSION_SCENE: PackedScene = preload ("res://Characters/Enemies/SpawnExplosion.tscn")

@onready var life_component: LifeComponent = get_node("../LifeComponent")

func _ready() -> void:
	life_component.died.connect(func() -> void:
		var explosion: AnimatedSprite2D=EXPLOSION_SCENE.instantiate()
		explosion.position=get_parent().global_position
		get_tree().current_scene.add_child(explosion)
	)
