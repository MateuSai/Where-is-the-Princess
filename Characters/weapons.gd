class_name Weapons extends Node2D

var current_weapon: Weapon: set = set_current_weapon

var reflection_sprite: Sprite2D

@onready var character: Character = get_parent()


func _ready() -> void:
	var reflection_container: Node2D = Node2D.new()
	reflection_container.z_index = -3
	reflection_container.modulate.a = 0.4
	reflection_container.scale.y = -1
	reflection_sprite = Sprite2D.new()
	reflection_container.add_child(reflection_sprite)
	get_parent().call_deferred("add_child", reflection_container)


func move(direction: Vector2) -> void:
	var prev_current_weap_rot: float = current_weapon.rotation
	current_weapon.move(direction)
	#if (prev_current_weap_rot > 0 and current_weapon.rotation < 0) or (prev_current_weap_rot < 0 and current_weapon.rotation > 0):
	if prev_current_weap_rot < 0 and current_weapon.rotation > 0:
		get_parent().move_child(self, -1)
	elif prev_current_weap_rot > 0 and current_weapon.rotation < 0:
		get_parent().move_child(self, 0)

	reflection_sprite.rotation = current_weapon.weapon_sprite.rotation
	reflection_sprite.position = current_weapon.weapon_sprite.position
	reflection_sprite.scale = current_weapon.weapon_sprite.scale


func set_current_weapon(new_weapon: Weapon) -> void:
		if current_weapon != null and current_weapon is MeleeWeapon:
			var a: Array[Node2D] = []
			(current_weapon as MeleeWeapon).hitbox.exclude = a

		current_weapon = new_weapon
		current_weapon.damage_dealer = character
		current_weapon.damage_dealer_id = character.id
		reflection_sprite.texture = current_weapon.weapon_sprite.texture
		reflection_sprite.offset = current_weapon.weapon_sprite.offset

		if current_weapon is MeleeWeapon:
			var a: Array[Node2D] = character.get_exclude_bodies()
			(current_weapon as MeleeWeapon).hitbox.exclude = a
