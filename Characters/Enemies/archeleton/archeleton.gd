class_name Archeleton extends Enemy

var projectile_speed: int = 200

@onready var bow_container: Node2D = $BowContainer
@onready var bow_sprite: Sprite2D = $BowContainer/Sprite2D
@onready var aim_component: AimComponent = $AimComponent


func aim_bow() -> void:
	bow_container.rotation = aim_component.get_dir().dir.angle()


func _spawn_arrow() -> void:
	var arrow: Arrow = load("res://Weapons/projectiles/arrow.tscn").instantiate()
#	arrow.position = bow_sprite.global_position
	arrow.launch(bow_sprite.global_position, Vector2.RIGHT.rotated(bow_container.rotation), projectile_speed, true)
	get_tree().current_scene.add_child(arrow)
