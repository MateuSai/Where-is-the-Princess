class_name TrompStealLifeAttack extends Area2D

var player: Player = null

var tromp: NecroTromp


func _init() -> void:
	body_entered.connect(func(body: Node2D) -> void:
		if body is Player:
			player = body
	)
	body_exited.connect(func(body: Node2D) -> void:
		if body is Player:
			player = null
	)


func _steal_life() -> void:
	if player:
		player.life_component.take_damage_ignoring_armor(1, Vector2.ZERO, 0, null, tromp.id)
		tromp.life_component.hp += 1
