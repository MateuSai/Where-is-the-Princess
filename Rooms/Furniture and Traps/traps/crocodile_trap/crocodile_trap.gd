class_name CrocodileTrap extends Area2D

const ATTACK_RANGE: int = 16
const BITE_EFFECT_SCENE: PackedScene = preload ("res://Characters/Enemies/BiteEffect.tscn")

var player_inside: bool = false

@export var knockback_dir: Vector2

@onready var sprite: Sprite2D = $Sprite2D
#@onready var range_shape: CircleShape2D = $CollisionShape2D.shape
#@onready var range_radius: float = range_shape.radius
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Hitbox = $Hitbox
@onready var hitbox_col: CollisionShape2D = $Hitbox/CollisionShape2D

func _ready() -> void:
	#set_process(false)
	sprite.frame = 0

	animation_player.animation_finished.connect(func(anim_name: String) -> void:
		if anim_name == "crocodile_trap_animation_library/bite" and player_inside:
			animation_player.play("crocodile_trap_animation_library/bite")
	)

	body_entered.connect(func(body: Node2D) -> void:
		if body is Player:
			player_inside=true
			#set_process(true)
			animation_player.clear_queue()
			#animation_player.stop()
			animation_player.play("crocodile_trap_animation_library/bite")
	)
	body_exited.connect(func(body: Node2D) -> void:
		if body is Player:
			player_inside=false
			#set_process(false)
			animation_player.clear_queue()
			animation_player.queue("crocodile_trap_animation_library/idle")
	)

	hitbox.damage_dealer_id = "crocodile"
	hitbox.knockback_direction = knockback_dir

#func _process(_delta: float) -> void:
	#if animation_player.is_playing():
		#return
#
	#var distance_to_player: float = (Globals.player.global_position - global_position).length()
	#if distance_to_player <= ATTACK_RANGE:
		#animation_player.play("bite_up")
	#else:
		#sprite.frame = round((1 - ((distance_to_player - ATTACK_RANGE) / (range_radius - ATTACK_RANGE))) * 6)

func _spawn_bite_effect() -> void:
	var bite_effect: Sprite2D = BITE_EFFECT_SCENE.instantiate()
	bite_effect.position = hitbox_col.global_position + knockback_dir * 8
	get_tree().current_scene.add_child(bite_effect)
