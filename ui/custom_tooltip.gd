class_name CustomTooltip extends MarginContainer

var title: String
var description: String

@onready var title_label: RichTextLabel = $MarginContainer/VBoxContainer/TitleLabel
@onready var description_label: RichTextLabel = $MarginContainer/VBoxContainer/DescriptionLabel


@warning_ignore("shadowed_variable")
func initialize(title: String, description: String) -> void:
	self.title = title
	self.description = description


func _ready() -> void:
	title_label.text = title
	description_label.text = description

	await get_tree().process_frame
	size.y = 0
