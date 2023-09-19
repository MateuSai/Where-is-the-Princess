class_name Hitbox extends Area2D

@export var damage: int = 1
var knockback_direction: Vector2 = Vector2.ZERO
@export var knockback_force: int = 300

var exclude: Array[Node2D] = []

signal collided_with_something(body: Node2D)

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

	body_entered.connect(_on_body_entered)
	body_exited.connect(_remove_entity_if_it_is_inside)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_remove_entity_if_it_is_inside)


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


func _on_body_entered(body: Node2D) -> void:
	collided_with_something.emit(body)
	_add_entity_if_node_has_one(body)


func _on_area_entered(area: Area2D) -> void:
	_add_entity_if_node_has_one(area)


func _collide(node: Node2D, dam: int = damage) -> void:
	#print(body.name)
	if node is Bomb:
		node.hit(knockback_direction, knockback_force)
	if node.has_node("LifeComponent"):
		node.get_node("LifeComponent").take_damage(dam, knockback_direction, knockback_force)
	elif node is RigidBody2D:
		node.apply_impulse(knockback_direction * knockback_force * 5)
	elif node is Projectile and node.can_be_destroyed:
		node.destroy()
	else:
		print_debug("Unhandled collision!")


func _get_entity(node: Node2D) -> Node2D:
	var entity: Node2D = null

	if node != null:
		entity = node.owner if node is HurtBox else node

	return entity
