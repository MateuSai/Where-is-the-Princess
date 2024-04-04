extends Control

var fade_tween: Tween

#@onready var panel: PanelContainer = %Panel
@onready var item_info_vbox: ItemInfoVBox = $MarginContainer/VBoxContainer
@onready var name_label: Label = item_info_vbox.name_label
@onready var description_label: RichTextLabel = item_info_vbox.description_label

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
	if item is PassiveItem and not SavedData.data.is_item_discovered(item as PassiveItem):
		description_label.text = "?"
	else:
		description_label.text = item.get_item_description()
	#size.y = 0

	position = pos
	modulate.a = 1.0
	show()

	# For some reason, I have to wait a frame
	await get_tree().process_frame
	size.y = 0

func stop_showing() -> void:
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.8)
