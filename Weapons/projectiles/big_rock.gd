class_name BigRock extends Projectile


const ROCK_CRUSH_EFFECT_SCENE: PackedScene = preload("res://effects/rock_crush_effect.tscn")


func destroy() -> void:
	var effect: Sprite2D = ROCK_CRUSH_EFFECT_SCENE.instantiate()
	effect.position = sprite.global_position
	get_tree().current_scene.add_child(effect)

	super()
