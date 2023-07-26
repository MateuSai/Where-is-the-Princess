class_name WeaponHitbox extends Hitbox


@export var player_damage_multiplier: bool = true


func _ready() -> void:
	super()
	area_entered.connect(func(area: Area2D):
		area.queue_free()
	)


func _collide(body: Node2D, _dam: int = damage) -> void:
	if player_damage_multiplier:
		super(body, damage * Globals.player.damage_multiplier)
	else:
		super(body, damage)
