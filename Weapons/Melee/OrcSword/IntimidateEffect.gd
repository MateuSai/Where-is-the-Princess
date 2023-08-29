extends Area2D


func _ready() -> void:
	body_entered.connect(func(body: Node):
		assert(body is Enemy)

		body.parallize()
	)
