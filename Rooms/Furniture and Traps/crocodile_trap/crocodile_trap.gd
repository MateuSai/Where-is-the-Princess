class_name CrocodileTrap extends Area2D

const ATTACK_RANGE: int = 16

@onready var sprite: Sprite2D = $Sprite2D
@onready var range_shape: CircleShape2D = $CollisionShape2D.shape
@onready var range_radius: float = range_shape.radius
@onready var animation_player: AnimationPlayer = $AnimationPlayer


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


func _process(_delta: float) -> void:
	var distance_to_player: float = (Globals.player.global_position - global_position).length()
	if distance_to_player <= ATTACK_RANGE:
		animation_player.play("bite_up")
	else:
		sprite.frame = round((1 - ((distance_to_player - ATTACK_RANGE) / (range_radius - ATTACK_RANGE))) * 6)
