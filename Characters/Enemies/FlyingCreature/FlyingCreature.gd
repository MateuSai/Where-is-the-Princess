@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/enemies/flying creature/fly_anim_f0.png")
class_name FlyingEnemy extends Enemy

const BITE_EFFECT_SCENE: PackedScene = preload("res://Characters/Enemies/BiteEffect.tscn")

@onready var hitbox_col: CollisionShape2D = $Hitbox/CollisionShape2D


func _ready() -> void:
	super()

	var pathfinding_component: PathfindingComponent = $PathfindingComponent
	assert(pathfinding_component.mode is PathfindingComponent.Approach)
	(pathfinding_component.mode as PathfindingComponent.Approach).flags |= PathfindingComponent.Approach.ZIG_ZAG_FLAG


func _spawn_bite_effect() -> void:
	var effect: Sprite2D = BITE_EFFECT_SCENE.instantiate()
	effect.global_position = hitbox_col.global_position
	get_tree().current_scene.add_child(effect)

