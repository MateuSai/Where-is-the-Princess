extends Control

@onready var border: ReferenceRect = get_node("ReferenceRect")
@onready var texture_rect: TextureRect = get_node("TextureRect")
@onready var condition_bar: TextureProgressBar = get_node("TextureProgressBar")


@warning_ignore("shadowed_variable_base_class")
func initialize(texture: Texture2D, condition: float) -> void:
	texture_rect.texture = texture
	condition_bar.value = condition


func select() -> void:
	border.show()


func deselect() -> void:
	border.hide()


func update_condition(new_condition: float) -> void:
	condition_bar.value = new_condition
