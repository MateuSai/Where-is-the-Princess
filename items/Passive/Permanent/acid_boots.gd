class_name AcidBoots extends PermanentPassiveItem

var player: Player

func _init() -> void:
	effects = [
		IncreasePlayerAcidProgressPerSecond.new( - 0.2),
		OnDashed.new([SpawnDashAcid.new()])
	]

#@warning_ignore("shadowed_variable")
#func equip(player: Player) -> void:
#	super(player)

#	self.player = player
#	player.dashed.connect(_on_dashed)

#@warning_ignore("shadowed_variable")
#func unequip(player: Player) -> void:
#	super(player)

#	player.dashed.disconnect(_on_dashed)

#func _on_dashed(dash_time: float) -> void:
#	var time: float = 0.0
#	var spawn_acid_interval: float = 0.03

#	while time <= (dash_time * 2.5):
#		var acid_puddle: Area2D = ACID_PUDDLE_SCENE.instantiate()
#		acid_puddle.position = player.global_position
#		player.get_tree().current_scene.add_child(acid_puddle)

#		time += spawn_acid_interval
#		await player.get_tree().create_timer(spawn_acid_interval).timeout

func get_icon() -> Texture2D:
	return load("res://Art/items/boots_acid_icon.png")

func get_big_icon() -> Texture2D:
	return load("res://Art/items/boots_acid_UI_desc.png")
