class_name Armor extends Resource

var name: String ## Name of the armor
var description: String ## Armor's description
var sprite_sheet: Texture ## Armor's spritesheet
var icon: Texture ## Icon of the armor

signal condition_changed(new_condition: int)
## The armor will also receive the damage taken by the player. When the condition reaches 0, the armor will be destroyed and you be in your underpants
@export var condition: int:
	set(new_condition):
		condition = clamp(new_condition, 0, max_condition)
		condition_changed.emit(condition)
var max_condition: int

var ability_icon: Texture
## Internal variable used to know if we can use the ability (when the cooldown time ends)
var is_able_to_use_ability: bool = true:
	set(new_value):
		if new_value != is_able_to_use_ability:
			is_able_to_use_ability = new_value
			if not is_able_to_use_ability:
				ability_used.emit()
signal ability_used()
var recharge_time: float ## Time the ability needs to recharge
var effect_duration: float ## Time the ability is active. For example, if the armor grants immortality, the time the player will be immortal.
signal ability_effect_ended()


@warning_ignore("shadowed_variable")
func initialize(name: String, description: String, sprite_sheet: Texture, icon: Texture, condition: int, ability_icon: Texture = null, recharge_time: float = 2, effect_duration: float = -1) -> void:
	self.name = name
	self.description = description
	self.sprite_sheet = sprite_sheet
	self.icon = icon
	self.max_condition = condition
	self.condition = condition
	self.ability_icon = ability_icon
	self.recharge_time = recharge_time
	self.effect_duration = effect_duration


func equip(_player: Player) -> void:
	pass


func unequip(_player: Player) -> void:
	pass


func enable_ability_effect(_player: Player) -> void:
	pass


func disable_ability_effect(_player: Player) -> void:
	pass
