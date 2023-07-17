class_name FireStatusComponent extends StatusComponent


func _init() -> void:
	initialize(2)


func add() -> void:
	get_parent().modulate = Color.RED
	super()


func remove() -> void:
	get_parent().modulate = Color.WHITE
	super()
