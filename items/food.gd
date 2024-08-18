class_name Food extends Item

const POSSIBLE_ICONS: Array[Texture2D] = [ preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/food_apple.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/food_banana.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/food_chicken.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/food_ham.png")]
const POSSIBLE_BIG_ICONS: Array[Texture2D] = [ preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Apple_UI_desc.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Banana_UI_desc.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Chicken_UI_desc.png"), preload ("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Ham_UI_desc.png")]

var icon: Texture2D
var big_icon: Texture2D

func _init() -> void:
	var rand_int: int = randi() % POSSIBLE_ICONS.size()
	icon = POSSIBLE_ICONS[rand_int]
	big_icon = POSSIBLE_BIG_ICONS[rand_int]

func get_coin_cost() -> int:
	return 9

func get_icon() -> Texture2D:
	return icon

func get_big_icon() -> Texture2D:
	return big_icon

func can_pick_up(player: Player) -> bool:
	return player.life_component.max_hp > player.life_component.hp

func pick_up(player: Player) -> void:
	super(player)

	player.life_component.hp += 1 + Globals.global_stats.food_extra_hp
	player.eat_sound.play()
