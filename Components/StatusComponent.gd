class_name StatusComponent extends Node

var life_component: LifeComponent

var charges: int


func initialize(charges: int) -> void:
	pass


func _ready() -> void:
	life_component = get_node_or_null("../LifeComponent")
	assert(life_component != null)
