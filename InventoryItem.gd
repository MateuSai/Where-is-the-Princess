extends Control

var weapon: Weapon

@onready var border: ReferenceRect = get_node("ReferenceRect")
@onready var texture_rect: TextureRect = get_node("TextureRect")
@onready var condition_bar: TextureProgressBar = get_node("TextureProgressBar")
@onready var status_container: HBoxContainer = get_node("StatusContainer")


@warning_ignore("shadowed_variable")
func initialize(weapon: Weapon) -> void:
	self.weapon = weapon
	texture_rect.texture = weapon.get_texture()
	condition_bar.value = weapon.stats.condition


func _ready() -> void:
	if get_index() == 0:
		condition_bar.queue_free()


func select() -> void:
	border.show()


func deselect() -> void:
	border.hide()


func update_condition(new_condition: float) -> void:
	condition_bar.value = new_condition


func add_status_icon(status: StatusComponent.Status) -> void:
	match status:
		StatusComponent.Status.FIRE:
			var icon: TextureRect = TextureRect.new()
			icon.texture = load("res://Art/weapon modifier icons/fire.png")
			status_container.add_child(icon)


func _get_tooltip(_at_position: Vector2) -> String:
	if get_tree().paused:
		return weapon.get_info()
	else:
		return ""


func _make_custom_tooltip(for_text: String) -> Object:
	var label: RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.text = for_text
	label.fit_content = true
	label.custom_minimum_size.x = 64
	label.add_theme_font_override("normal_font", load("res://Fonts/Poco.ttf"))
	label.add_theme_font_size_override("normal_font_size", 10)
#	var label_settings: LabelSettings = LabelSettings.new()
#	label_settings.font = load("res://Fonts/Poco.ttf")
#	label_settings.font_size = 10
#	label.label_settings = label_settings
	return label
