class_name HangedSkeleton extends Sprite2D

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

func _ready() -> void:
    frame_coords.y = randi() % vframes

    animation_player.play("swing")