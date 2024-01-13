class_name TrompFSM extends FiniteStateMachine

enum {
	ATTACK,
	DEAD,
}

@onready var tromp: NecroTromp = get_parent()
@onready var weapons: EnemyWeapons = $"../EnemyWeapons"
#@onready var attack_timer: Timer = $"../AttackTimer"


func start() -> void:
	set_state(ATTACK)


func _state_logic(_delta: float) -> void:
	if state == ATTACK:
		if not weapons.is_busy() and (weapons.current_weapon as NecromancerScepter).num_skeletons_alive < NecromancerScepter.MAX_NUM_SKELETONS_ALIVE:
			#weapons.attack()
			pass
			#weapons.active_ability()
			#tromp._spawn_skeletons()
			#attack_timer.start(1.0)
