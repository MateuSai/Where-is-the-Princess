extends PanelContainer

var fade_tween: Tween

#@onready var panel: PanelContainer = %Panel
@onready var name_label: Label = %NameLabel
@onready var description_label: RichTextLabel = %DescriptionLabel


func _ready() -> void:
	hide()


func show_at(pos: Vector2, item: Item) -> void:
	if fade_tween:
		fade_tween.kill()
		fade_tween = null

	name_label.text = item.get_item_name()
	match item.get_quality():
		Item.Quality.COMMON:
			name_label.modulate = Color.WHITE
		Item.Quality.CHINGON:
			name_label.modulate = Color.BLUE
	description_label.text = item.get_item_description()
	#size.y = 0

	position = pos
	modulate.a = 1.0
	show()

	# For some reason, I have to write a frame
	await get_tree().process_frame
	size.y = 0


func stop_showing() -> void:
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.8)
