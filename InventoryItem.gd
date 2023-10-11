extends MarginContainer

var weapon: Weapon

@onready var texture_rect: TextureRect = $Background/VBoxContainer/TextureRect
@onready var condition_bar: TextureProgressBar = $Background/VBoxContainer/TextureProgressBar
@onready var status_container: HBoxContainer = %StatusContainer


@warning_ignore("shadowed_variable")
func initialize(weapon: Weapon) -> void:
	self.weapon = weapon
	texture_rect.texture = weapon.get_texture()
	condition_bar.value = weapon.stats.condition
	if weapon.name == "Dagger":
		condition_bar.value = 100
		condition_bar.tint_progress = Color.SILVER
	else:
		update_condition(weapon.stats.condition)


#func _ready() -> void:
#	if get_index() == 0:
#		condition_bar.queue_free()


func select() -> void:
	modulate = Color.WHITE


func deselect() -> void:
	modulate = Color("#767676")


func update_condition(new_condition: float) -> void:
	condition_bar.value = new_condition
	if new_condition > 50:
		condition_bar.tint_progress = Color.YELLOW.lerp(Color.GREEN, (new_condition - 50) / 50)
	else:
		condition_bar.tint_progress = Color.RED.lerp(Color.YELLOW, new_condition / 50)


func add_status_icon(status: StatusComponent.Status) -> void:
#	match status:
#		StatusComponent.Status.FIRE:
	var icon: TextureRect = TextureRect.new()
	icon.texture = load(["res://Art/16x16 Pixel Art Roguelike (Forest) Pack/Items/Ruby_icon.png", "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/Items/Zaphire_icon.png", "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/Items/Topaz_icon.png"][status])
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
	label.add_theme_font_override("normal_font", load("res://Fonts/small_font.tres"))
	label.add_theme_font_size_override("normal_font_size", 10)
#	var label_settings: LabelSettings = LabelSettings.new()
#	label_settings.font = load("res://Fonts/Poco.ttf")
#	label_settings.font_size = 10
#	label.label_settings = label_settings
	return label
