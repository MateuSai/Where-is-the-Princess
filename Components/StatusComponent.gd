class_name StatusComponent extends Node

var life_component: LifeComponent

enum Status {
	FIRE,
	ICE,
	LIGHTNING,
	ACID,
}

@onready var character: Character = get_parent()

#func _init() -> void:
#	fill_mode = FILL_BOTTOM_TO_TOP

func _ready() -> void:
	life_component = get_node_or_null("../LifeComponent")
	assert(life_component != null)

func add() -> void:
	pass

func remove() -> void:
	queue_free()
