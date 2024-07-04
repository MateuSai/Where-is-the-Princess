class_name NecroTromp extends Enemy

#const NECROMANCER_SPAWN: PackedScene = preload("res://Characters/necromancer_spawn/necromancer_spawn.tscn")

var bald: bool = false

@onready var weapons: EnemyWeapons = $EnemyWeapons

func _ready() -> void:
	super()

	life_component.hp_changed.connect(func(new_hp: int) -> void:
		if not bald and new_hp <= life_component.max_hp / 2.0:
			bald=true
			_change_to_bald_mode()
	)

func _process(_delta: float) -> void:
	if is_instance_valid(weapons):
		weapons.move((target.global_position - global_position).normalized())

func _change_to_bald_mode() -> void:
	react(Reaction.VERY_MAD)
	sprite.texture = load("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Tromp the necromancer/Tromp_02.png")
	var hair: TrompHair = load("res://Characters/Enemies/necro_tromp/tromp_hair.tscn").instantiate()
	hair.position = global_position + Vector2.UP * 8
	get_tree().current_scene.add_child(hair)

func _on_died() -> void:
	if not SavedData.achievements.is_achievement_completed(Achievements.Achievement.sewer_necromancer):
		SavedData.complete_achievement(Achievements.Achievement.sewer_necromancer)

		var armor_path: String = "res://Armors/necromancer_armor/necromancer_armor.gd"
		SavedData.discover_armor_if_not_already(armor_path)
		(get_tree().current_scene as Game).show_notification(load("res://ui/notifications/armor_unlocked_notification.tscn"), {
			"id": Armor.get_id_from_path(armor_path).to_upper(),
			"icon": (load(armor_path).new() as Armor).get_icon(),
		})

	super()

#func _spawn_skeletons(amount: int = 1) -> void:
	#for i: int in amount:
		#var necromancer_spawn: NecromancerSpawn = NECROMANCER_SPAWN.instantiate()
		#necromancer_spawn.position = position + Vector2.RIGHT.rotated(randf_range(0.0, 2*PI)) * randf_range(16, 64)
		#get_parent().add_child(necromancer_spawn)
