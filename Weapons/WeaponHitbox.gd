class_name WeaponHitbox extends Hitbox


@export var player_damage_multiplier: bool = true


func _ready() -> void:
	super()


func _collide(body: Node2D, _dam: int = damage) -> void:
	if player_damage_multiplier:
		super(body, damage * Globals.player.damage_multiplier)
	else:
		super(body, damage)
