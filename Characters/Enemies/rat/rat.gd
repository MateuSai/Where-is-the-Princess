class_name Rat extends Enemy


const BITE_EFFECT_SCENE: PackedScene = preload("res://Characters/Enemies/BiteEffect.tscn")

@onready var flock_steering: FlockSteering = $FlockSteering
@onready var hitbox_col: CollisionShape2D = $Hitbox/CollisionShape2D


func _ready() -> void:
	super()

	var possible_textures: Array[Texture] = [load("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Rat/Rat.png"), load("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Rat/Rat_02.png"), load("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Rat/Rat_03.png")]
	sprite.texture = possible_textures[randi() % possible_textures.size()]


func _spawn_bite_effect() -> void:
	var effect: Sprite2D = BITE_EFFECT_SCENE.instantiate()
	effect.global_position = hitbox_col.global_position
	get_tree().current_scene.add_child(effect)


func move_to_leader(leader: Character) -> void:
	if not navigation_agent.is_target_reached():
		if can_move:
			var dir: Vector2 = leader.mov_direction.normalized()

			dir += flock_steering._get_separation_steering()
			dir += flock_steering._get_cohesion_steering()

			mov_direction = mov_direction.lerp(dir.normalized(), 0.15)
			if mov_direction.x > 0 and sprite.flip_h:
				_on_change_dir()
			elif mov_direction.x < 0 and not sprite.flip_h:
				_on_change_dir()
		else:
			mov_direction = Vector2.ZERO
