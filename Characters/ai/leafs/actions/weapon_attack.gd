class_name WeaponAttack extends ActionLeaf

enum AttackType {
	NORMAL,
	ACTIVE_ABILITY,
}

@export var attack_type: AttackType = AttackType.NORMAL

@onready var enemy_weapons: EnemyWeapons = owner.get_node("EnemyWeapons")

var attacking: bool = false
var just_finished_attack: bool = false

func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if just_finished_attack:
		just_finished_attack = false
		return SUCCESS

	if not attacking:
		attacking = true
		enemy_weapons.current_weapon.animation_player.animation_finished.connect(_on_attack_animation_ended)
		if attack_type == AttackType.NORMAL:
			if enemy_weapons.current_weapon is Bow:
				if enemy_weapons.current_weapon.animation_player.is_playing() and enemy_weapons.current_weapon.get_current_animation().begins_with("charge") and enemy_weapons.current_weapon.is_charging() and enemy_weapons.current_weapon.weapon_sprite.frame > 0:
					enemy_weapons.current_weapon._bow_attack(enemy_weapons.current_weapon.animation_player.current_animation_position / enemy_weapons.current_weapon.animation_player.current_animation_length)
				elif enemy_weapons.current_weapon.is_charging() and not enemy_weapons.current_weapon.animation_player.is_playing():
					enemy_weapons.current_weapon._bow_attack(1.0)
				else:
					enemy_weapons.current_weapon.animation_player.play("RESET")
			else:
				enemy_weapons.attack()
		else:
			enemy_weapons.active_ability()

	return RUNNING

func _on_attack_animation_ended(_anim_name: String) -> void:
	attacking = false
	just_finished_attack = true
	enemy_weapons.current_weapon.animation_player.animation_finished.disconnect(_on_attack_animation_ended)
