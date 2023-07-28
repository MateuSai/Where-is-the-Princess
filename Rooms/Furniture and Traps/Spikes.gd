extends Hitbox


@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")


func _ready() -> void:
	super()
	#animation_player.play("pierce")


func _collide(body: Node2D, dam: int = damage) -> void:
	if not body.get("is_flying") or not body.flying:
		knockback_direction = (body.global_position - global_position).normalized()
		super(body, dam)

