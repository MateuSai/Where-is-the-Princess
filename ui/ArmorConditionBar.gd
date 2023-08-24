class_name ArmorConditionBar extends TextureProgressBar

const START_AT_VALUE: int = 29

var tween: Tween
var armor_ability_tween: Tween

var current_armor: Armor

@onready var player: Player = owner

@onready var armor_ability_bar: TextureProgressBar = $ArmorAbilityBar


func _ready() -> void:
	player.armor_changed.connect(_on_armor_changed)


func _update_armor_condition(new_condition: int) -> void:
	tween = create_tween()
	tween.tween_property(self, "value", START_AT_VALUE + (new_condition/float(current_armor.max_condition)) * (100 - START_AT_VALUE), 1)


func _on_armor_changed(new_armor: Armor) -> void:
	assert(new_armor)
	current_armor = new_armor
	new_armor.condition_changed.connect(_on_armor_condition_changed)
	_update_armor_condition(new_armor.condition)

	armor_ability_bar.texture_under = new_armor.ability_icon
	armor_ability_bar.texture_progress = new_armor.ability_icon
	armor_ability_bar.value = 100
	new_armor.ability_used.connect(_on_armor_ability_used)
	new_armor.ability_effect_ended.connect(_on_armor_ability_effect_ended)


func _on_armor_condition_changed(new_condition: int) -> void:
	_update_armor_condition(new_condition)


func _on_armor_ability_used() -> void:
	armor_ability_bar.value = 0


func _on_armor_ability_effect_ended() -> void:
	armor_ability_tween = create_tween()
	armor_ability_tween.tween_property(armor_ability_bar, "value", 100, current_armor.recharge_time)
