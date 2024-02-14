class_name BoltSprite extends Sprite2D

@onready var weapon: Crossbow = owner


func _ready() -> void:
	weapon.ready.connect(func() -> void:
		texture = Bolt.TEXTURES[weapon.arrow_type]
		weapon.arrow_type_changed.connect(func(new_type: ArrowOrBolt.Type) -> void:
			texture = Bolt.TEXTURES[new_type]
		)
	)
