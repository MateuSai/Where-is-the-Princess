class_name ArmorConditionBar extends TextureProgressBar

const ARMOR_SHINE_EFFECT: PackedScene = preload ("res://ui/ArmorAbilityShineEffect.tscn")

const START_AT_VALUE: int = 29

var armor_condition_tween: Tween
var armor_ability_tween: Tween

var current_armor: Armor

@onready var player: Player = owner

@onready var armor_ability_bar: TextureProgressBar = $ArmorAbilityBar

func _ready() -> void:
	player.armor_changed.connect(_on_armor_changed)

func _update_armor_condition(new_condition: int) -> void:
	if is_instance_valid(armor_condition_tween) and armor_condition_tween.is_running():
		armor_condition_tween.kill()
		armor_condition_tween = null
	armor_condition_tween = create_tween()
	#print(str(START_AT_VALUE + (new_condition/float(current_armor.max_condition))))
	#print(str(START_AT_VALUE + (new_condition/float(current_armor.max_condition)) * (100 - START_AT_VALUE)))
	armor_condition_tween.tween_property(self, "value", START_AT_VALUE + (new_condition / float(current_armor.max_condition)) * (100 - START_AT_VALUE), 0.8).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)

func _on_armor_changed(new_armor: Armor) -> void:
	assert(new_armor)

	if current_armor:
		if current_armor.condition_changed.is_connected(_on_armor_condition_changed):
			current_armor.condition_changed.disconnect(_on_armor_condition_changed)
		if current_armor.ability_used.is_connected(_on_armor_ability_used):
			current_armor.ability_used.disconnect(_on_armor_ability_used)
		if current_armor.ability_effect_ended.is_connected(_on_armor_ability_effect_ended):
			current_armor.ability_effect_ended.disconnect(_on_armor_ability_effect_ended)

	current_armor = new_armor

	armor_ability_bar.texture_under = new_armor.ability_icon
	armor_ability_bar.texture_progress = new_armor.ability_icon
	armor_ability_bar.value = 100
	if new_armor is Underpants:
		value = 0
	else:
		new_armor.condition_changed.connect(_on_armor_condition_changed)
		_update_armor_condition(new_armor.condition)
	new_armor.ability_used.connect(_on_armor_ability_used)
	new_armor.ability_effect_ended.connect(_on_armor_ability_effect_ended)

func _on_armor_condition_changed(new_condition: int) -> void:
	_update_armor_condition(new_condition)

func _on_armor_ability_used() -> void:
	armor_ability_bar.value = 0

func _on_armor_ability_effect_ended() -> void:
	armor_ability_tween = create_tween()
	armor_ability_tween.tween_property(armor_ability_bar, "value", 100, player.get_armor_recharge_time())
	await armor_ability_tween.finished
	var shine_effect: Sprite2D = ARMOR_SHINE_EFFECT.instantiate()
	shine_effect.position = armor_ability_bar.position
	add_child(shine_effect)
#	armor_ability_tween.tween_property(armor_ability_bar, "scale", Vector2(1.1, 1.1), 0.07)
#	armor_ability_tween.tween_property(armor_ability_bar, "scale", Vector2.ONE, 0.07)
