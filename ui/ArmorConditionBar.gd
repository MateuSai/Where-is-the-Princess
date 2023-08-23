class_name ArmorConditionBar extends TextureProgressBar

const START_AT_VALUE: int = 29

var tween: Tween

@onready var player: Player = owner


func _ready() -> void:
	player.armor_changed.connect(func(new_armor: Armor):
		new_armor.condition_changed.connect(func(new_condition: int):
			_update_armor_condition(new_condition, new_armor.max_condition)
		)
		_update_armor_condition(new_armor.max_condition, new_armor.max_condition)
	)


func _update_armor_condition(new_condition: int, max_condition: int) -> void:
	tween = create_tween()
	tween.tween_property(self, "value", START_AT_VALUE + (new_condition/float(max_condition)) * (100 - START_AT_VALUE), 1)
