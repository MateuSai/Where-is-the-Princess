class_name Hitbox extends Area2D

@export var damage: int = 1
var knockback_direction: Vector2 = Vector2.ZERO
@export var knockback_force: int = 300

var exclude: Array[Node2D] = []
var exclude_rid: Array[RID] = []

var weapon: Weapon = null
var damage_dealer: Node = null
var damage_dealer_id: String

signal collided_with_something(node: Node2D)

@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var timer: Timer = Timer.new()

enum CollisionMaterial {
	FLESH,
	STONE,
}
# personajes a los quales hemos hecho daño. Se va a vaciar cada vez que el timer termine
var entities_inside: Array = []

func _ready() -> void:
	assert(collision_shape != null)
	timer.wait_time = 1
	add_child(timer)

	body_shape_entered.connect(_on_body_shape_entered)
	body_shape_exited.connect(_on_body_shape_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_remove_entity_if_it_is_inside)

	if owner and not owner is Weapon:
		owner.ready.connect(func() -> void:
			if owner.get("id") != null:
				damage_dealer_id=owner.id
			damage_dealer=owner
		)

func _add_entity(entity: Node2D) -> void:
	assert(not entity in entities_inside)
	entities_inside.push_back(entity)

func _remove_entity(entity: Node2D) -> void:
	assert(entity in entities_inside)
	entities_inside.erase(entity)

func _add_entity_if_node_has_one(node: Node2D) -> void:
	var entity_target: Node2D = _get_entity(node)

	if entity_target:
		if exclude.size() > 0:
			if exclude.has(entity_target):
				return

		if not entities_inside.has(entity_target):
			_add_entity(entity_target)
			_loop_and_collide(entity_target)
			# characters_inside.push_back(character_target)
		else:
			# ya estamos haciendo daño a este personaje
			return

# las señales body_exited y area_exited estan conectadas a esta función. Si node forma parte de un personaje, lo eliminamos del array de los personajes que hay dentro
func _remove_entity_if_it_is_inside(node: Node2D) -> void:
	var entity_target: Node2D = _get_entity(node)
	if entity_target:
		if entities_inside.has(entity_target):
			_remove_entity(entity_target)
			#characters_inside.erase(character_target)

func _loop_and_collide(entity_target: Node2D) -> void:
	#incluso aca, se podria hacer que los ataques cuerpo a cuerpo tuvieran un animacion de tiempo similar
	#o definirse mediante una variable
	timer.start()
	#se podria anteponer una condicional que si es parte de un grupo o mask se haga el daño, en este caso
	#un posible hurt box, con un area 2d como padre y en un layer/grupo propio
	while entities_inside.has(entity_target):
		_collide(entity_target)
		#el bucle while no se reiniciara hasta que se alcance el timeout del timer establecido por variable
		await timer.timeout

	timer.stop()

func _on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	Log.debug("Hitbox collided with rid: " + str(body_rid) + "   exclude_rid: " + str(exclude_rid))

	if exclude_rid.has(body_rid):
		return

	_add_entity_if_node_has_one(body)

func _on_body_shape_exited(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if exclude_rid.has(body_rid):
		return

	_remove_entity_if_it_is_inside(body)

func _on_area_entered(area: Area2D) -> void:
	_add_entity_if_node_has_one(area)

func _collide(node: Node2D, dam: int=damage) -> void:
	collided_with_something.emit(node)

	#print(body.name)
	if node.has_node("LifeComponent"):
		#Log.debug("hitbox damaging " + node.name)
		(node.get_node("LifeComponent") as LifeComponent).take_damage(dam, knockback_direction, knockback_force, weapon, damage_dealer, damage_dealer_id)
	elif node.has_method("hit"): # Bomb
		node.hit(knockback_direction, knockback_force)
	elif node is RigidBody2D:
		(node as RigidBody2D).apply_impulse(knockback_direction * knockback_force * 5)
	elif node is Projectile and (node as Projectile).can_be_destroyed:
		(node as Projectile).destroy()
	else:
		print_debug("Unhandled collision!")

func _get_entity(node: Node2D) -> Node2D:
	var entity: Node2D = null

	if node != null:
		entity = node.get_parent() if node is HurtBox else node

	return entity
