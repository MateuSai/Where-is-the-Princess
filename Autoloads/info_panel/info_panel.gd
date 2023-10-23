extends PanelContainer

var fade_tween: Tween

#@onready var panel: PanelContainer = %Panel
@onready var name_label: Label = %NameLabel
@onready var description_label: RichTextLabel = %DescriptionLabel


func _ready() -> void:
	hide()


func show_at(pos: Vector2, item_name: String, item_description: String) -> void:
	if fade_tween:
		fade_tween.kill()
		fade_tween = null

	name_label.text = item_name
	description_label.text = item_description

	position = pos
	modulate.a = 1.0
	show()


func stop_showing() -> void:
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.8)
