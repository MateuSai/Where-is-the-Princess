@tool

class_name ArrowSprite extends Sprite2D

@onready var weapon: Bow = owner

func _ready() -> void:
	weapon.ready.connect(func() -> void:
		texture=Arrow.TEXTURES[weapon.arrow_type]
		weapon.arrow_type_changed.connect(func(new_type: ArrowOrBolt.Type) -> void:
			texture=Arrow.TEXTURES[new_type]
		)
	)
