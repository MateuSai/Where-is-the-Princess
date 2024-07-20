class_name FreeOnDied extends Node

@onready var life_component: LifeComponent = get_node("../LifeComponent")

func _ready() -> void:
	life_component.died.connect(get_parent().queue_free, CONNECT_ONE_SHOT)
