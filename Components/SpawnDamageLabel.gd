class_name SpawnDamageLabel extends Node

var life_component: LifeComponent

@onready var character: Node2D = get_parent()


func _ready() -> void:
	life_component = get_node_or_null("../LifeComponent")
	assert(life_component)

	if Settings.damage_numbers:
		life_component.damage_taken.connect(_spawn_label)

	Settings.damage_numbers_changed.connect(func(new_value: bool):
		if new_value and not life_component.damage_taken.is_connected(_spawn_label):
			life_component.damage_taken.connect(_spawn_label)
		elif not new_value and life_component.damage_taken.is_connected(_spawn_label):
			life_component.damage_taken.disconnect(_spawn_label)
	)


func _spawn_label(dam: int, dir: Vector2, _force: int) -> void:
	var label: DamageLabel = DamageLabel.new()
	get_tree().current_scene.add_child(label)
	label.spawn(dam, dir, character.global_position + character.get_node("Sprite2D").position)
#	label.theme = load("res://SmallFontTheme.tres")
#	label.z_index = 2
#	label.text = str(dam)
#	label.position = character.global_position

#	var tween: Tween = create_tween()
#	tween.set_parallel(true)
#	tween.tween_property(label, "position", character.global_position + dir * 16, 0.7)
#	tween.tween_property(label, "modulate:a", 0.0, 0.7)
#	await tween.finished
#	label.queue_free()


class DamageLabel extends Label:
	func _init() -> void:
		theme = load("res://SmallFontTheme.tres")
		add_theme_color_override("font_outline_color", Color.BLACK)
		add_theme_constant_override("outline_size", 2)
		z_index = 2

	func spawn(dam: int, dir: Vector2, pos: Vector2) -> void:
		#print(theme.get_font_size("font_size", ""))
		text = str(dam)
		pos.y -= theme.get_font_size("font_size", "") * 0.5
		pos.x -= text.length() * theme.get_font_size("font_size", "") * 0.5
		position = pos

		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "position", pos + dir * 32, 0.6)
		tween.tween_property(self, "modulate:a", 0.0, 0.6)
		tween.finished.connect(queue_free)
