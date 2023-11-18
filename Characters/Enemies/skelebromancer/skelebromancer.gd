class_name Skelebromancer extends Enemy

@onready var eyes_sprite: Sprite2D = $EyesSprite


func _on_change_dir() -> void:
	super()

	eyes_sprite.flip_h = !eyes_sprite.flip_h
