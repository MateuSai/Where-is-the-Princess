class_name InsectorMusk extends Enemy

const BITE_EFFECT_SCENE: PackedScene = preload("res://Characters/Enemies/BiteEffect.tscn")
const ACID_SPIT_SCENE: PackedScene = preload("res://Weapons/projectiles/acid_spit/acid_spit.tscn")

@onready var hitbox_col: CollisionShape2D = $Hitbox/CollisionShape2D


func _spawn_bite_effect() -> void:
	var effect: Sprite2D = BITE_EFFECT_SCENE.instantiate()
	effect.global_position = hitbox_col.global_position
	get_tree().current_scene.add_child(effect)


func spit() -> void:
	var spit: AcidSpit = ACID_SPIT_SCENE.instantiate()
	get_tree().current_scene.add_child(spit)
	spit.launch(global_position, (target.global_position - global_position).normalized(), 200)
