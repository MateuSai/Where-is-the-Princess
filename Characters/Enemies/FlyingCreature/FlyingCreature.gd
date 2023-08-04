@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/enemies/flying creature/fly_anim_f0.png")
class_name FlyingEnemy extends Enemy

const BITE_EFFECT_SCENE: PackedScene = preload("res://Characters/Enemies/BiteEffect.tscn")

@onready var hitbox_col: CollisionShape2D = $Hitbox/CollisionShape2D


func _spawn_bite_effect() -> void:
	var effect: Sprite2D = BITE_EFFECT_SCENE.instantiate()
	effect.global_position = hitbox_col.global_position
	get_tree().current_scene.add_child(effect)

