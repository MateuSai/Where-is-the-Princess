class_name WeaponNormalAttack extends ActionLeaf

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
        enemy_weapons.attack()

    return RUNNING

func _on_attack_animation_ended(_anim_name: String) -> void:
    attacking = false
    just_finished_attack = true
    enemy_weapons.current_weapon.animation_player.animation_finished.disconnect(_on_attack_animation_ended)