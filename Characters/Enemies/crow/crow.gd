class_name Crow extends Enemy

const BITE_EFFECT_SCENE: PackedScene = preload("res://Characters/Enemies/BiteEffect.tscn")

@onready var _hitbox_col: CollisionShape2D = $Hitbox/CollisionShape2D

func _ready() -> void:
	super()

	_hitbox_col.disabled = true

# Crow has four direction animation, the sprite's flip_h property is determined on the animations
func _on_change_dir() -> void:
	pass

func _bite() -> void:
	_hitbox_col.disabled = false
	var bite_effect: Node = BITE_EFFECT_SCENE.instantiate()
	bite_effect.position = _hitbox_col.global_position
	get_tree().current_scene.add_child(bite_effect)

	await get_tree().create_timer(0.1, false).timeout

	_hitbox_col.disabled = true
