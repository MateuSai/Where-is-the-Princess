class_name CrocodileTrap extends Area2D

const ATTACK_RANGE: int = 16
const BITE_EFFECT_SCENE: PackedScene = preload("res://Characters/Enemies/BiteEffect.tscn")

@onready var sprite: Sprite2D = $Sprite2D
@onready var range_shape: CircleShape2D = $CollisionShape2D.shape
@onready var range_radius: float = range_shape.radius
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Hitbox = $Hitbox
@onready var hitbox_col: CollisionShape2D = $Hitbox/CollisionShape2D


func _ready() -> void:
	set_process(false)
	sprite.frame = 0

	body_entered.connect(func(body: Node2D) -> void:
		if body is Player:
			set_process(true)
	)
	body_exited.connect(func(body: Node2D) -> void:
		if body is Player:
			set_process(false)
	)

	hitbox.knockback_direction = Vector2.UP


func _process(_delta: float) -> void:
	if animation_player.is_playing():
		return

	var distance_to_player: float = (Globals.player.global_position - global_position).length()
	if distance_to_player <= ATTACK_RANGE:
		animation_player.play("bite_up")
	else:
		sprite.frame = round((1 - ((distance_to_player - ATTACK_RANGE) / (range_radius - ATTACK_RANGE))) * 6)


func _spawn_bite_effect() -> void:
	var bite_effect: Sprite2D = BITE_EFFECT_SCENE.instantiate()
	bite_effect.position = hitbox_col.global_position + Vector2.UP * 8
	get_tree().current_scene.add_child(bite_effect)
