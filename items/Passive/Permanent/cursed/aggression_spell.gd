class_name AggressionSpell extends PermanentPassiveItem


var player: Player = null
var damage_doubled: bool = false


@warning_ignore("shadowed_variable")
func equip(player: Player) -> void:
	self.player = player

	player.life_component.hp_changed.connect(_on_player_hp_changed)
	_on_player_hp_changed(player.life_component.hp)


func unequip(_player: Player) -> void:
	player.life_component.hp_changed.disconnect(_on_player_hp_changed)
	if player.weapons.normal_attacked.is_connected(_on_character_received_damage):
		player.weapons.normal_attacked.disconnect(_on_character_received_damage)
	if damage_doubled:
		player.damage_multiplier /= 2.0


func _on_player_hp_changed(new_hp: int) -> void:
	if new_hp == player.life_component.max_hp:
		player.damage_multiplier *= 2.0
		damage_doubled = true
		Globals.character_received_damage.connect(_on_character_received_damage)
	elif damage_doubled:
		player.damage_multiplier /= 2.0
		damage_doubled = false
		Globals.character_received_damage.disconnect(_on_character_received_damage)


func _on_character_received_damage(character: Character, damage_dealer: Character) -> void:
	if not character is Player and damage_dealer is Player:
		player.life_component.take_damage_ignoring_armor(2, Vector2.ZERO, 0, null, player, player.id)


func get_icon() -> Texture2D:
	return load("res://Art/items/Agression_spell.png")
