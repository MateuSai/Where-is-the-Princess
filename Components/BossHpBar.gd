class_name BossHpBar extends CanvasLayer

const MAX_HP_MULTIPLIER: int = 3

var bar_tween: Tween

var max_hp: int

@export var top_margin: int = 13

@onready var enemy: Enemy = get_parent()
@onready var life_component: LifeComponent = enemy.get_node("LifeComponent")

@onready var vbox: VBoxContainer = $HBoxContainer/VBoxContainer
@onready var name_label: Label = %NameLabel
@onready var hp_bar: TextureProgressBar = %HpBar


func _ready() -> void:
	await enemy.ready

	($HBoxContainer/VBoxContainer/MarginContainer as MarginContainer).add_theme_constant_override("margin_top", top_margin)

	name_label.text = enemy.name

	max_hp = life_component.max_hp
	vbox.custom_minimum_size.x = max_hp * MAX_HP_MULTIPLIER

	_update_bar(life_component.max_hp, life_component.max_hp)
	life_component.hp_changed.connect(func(new_hp: int) -> void:
		_update_bar(new_hp, life_component.max_hp)
	)


@warning_ignore("shadowed_variable")
func _update_bar(hp: int, max_hp: int) -> void:
	if self.max_hp != max_hp:
		_set_max_hp(max_hp)

	bar_tween = create_tween()
	bar_tween.tween_property(hp_bar, "value", (float(hp) / max_hp) * 100, 0.8)


func _set_max_hp(new_value: int) -> void:
	max_hp = new_value
	create_tween().tween_property(vbox, "custom_minimum_size:x", max_hp * MAX_HP_MULTIPLIER, 0.8)
