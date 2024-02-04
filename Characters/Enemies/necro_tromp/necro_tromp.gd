class_name NecroTromp extends Enemy

#const NECROMANCER_SPAWN: PackedScene = preload("res://Characters/necromancer_spawn/necromancer_spawn.tscn")

var bald: bool = false


@onready var weapons: EnemyWeapons = $EnemyWeapons


func _ready() -> void:
	super()

	life_component.hp_changed.connect(func(new_hp: int) -> void:
		if not bald and new_hp <= life_component.max_hp/2.0:
			bald = true
			_change_to_bald_mode()
	)


func _process(_delta: float) -> void:
	weapons.move((target.global_position - global_position).normalized())


func _change_to_bald_mode() -> void:
	react(Reaction.VERY_MAD)
	sprite.texture = load("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Tromp the necromancer/Tromp_02.png")
	var hair: TrompHair = load("res://Characters/Enemies/necro_tromp/tromp_hair.tscn").instantiate()
	hair.position = global_position + Vector2.UP * 8
	get_tree().current_scene.add_child(hair)


#func _spawn_skeletons(amount: int = 1) -> void:
	#for i: int in amount:
		#var necromancer_spawn: NecromancerSpawn = NECROMANCER_SPAWN.instantiate()
		#necromancer_spawn.position = position + Vector2.RIGHT.rotated(randf_range(0.0, 2*PI)) * randf_range(16, 64)
		#get_parent().add_child(necromancer_spawn)
