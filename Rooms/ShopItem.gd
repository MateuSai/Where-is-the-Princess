class_name ShopItem extends ItemOnFloor

const HOLOGRAM_SHADER: Shader = preload("res://shaders_and_particles/hologram.gdshader")
const HOLOGRAM_TEXTURE: Texture = preload("res://Art/hologram_lines-b1399a8d.png")

var price: int = 10
var price_always_visible: bool

@onready var price_container: HBoxContainer = $HBoxContainer
@onready var price_label: Label = %PriceLabel
@onready var currency_icon: TextureRect = $HBoxContainer/TextureRect


@warning_ignore("shadowed_variable")
func initialize(item: Item) -> void:
	super(item)

	price_always_visible = Settings.shop_prices_always_visible
	Settings.shop_prices_always_visible_changed.connect(func(new_value: bool):
		price_always_visible = new_value
		if price_always_visible:
			price_container.show()
		elif not is_processing_unhandled_input():
			price_container.hide()
	)

	if get_tree().current_scene.name == "Game":
		await get_tree().current_scene.player_added
		_update_coin_price(Globals.player.shop_discount)
		Globals.player.shop_discount_changed.connect(func(new_value: float):
			_update_coin_price(new_value)
		)
#		price = round(item.get_coin_cost() * (1 - Globals.player.shop_discount))
		currency_icon.texture = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/small_coin.tres")
	else: # BaseCamp
		assert(get_tree().current_scene.name == "BaseCamp")

		price = item.get_dark_soul_cost()
		currency_icon.texture = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/8x8_boss_soul_animation.tres")
		#currency_icon.texture = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/small_coin.tres")

		var hologram_sprite: Sprite2D = Sprite2D.new()
		hologram_sprite.texture = texture
		hologram_sprite.material = ShaderMaterial.new()
		hologram_sprite.material.shader = HOLOGRAM_SHADER
		hologram_sprite.material.set_shader_parameter("hologramTexture", HOLOGRAM_TEXTURE)
		add_child(hologram_sprite)

		price_label.text = str(price)


func _ready() -> void:
	super()

	interact_area.player_entered.connect(func():
		if not price_always_visible:
			price_container.show()
	)
	interact_area.player_exited.connect(func():
		if not price_always_visible:
			price_container.hide()
	)

	enable_pick_up()

func _update_coin_price(discount: float) -> void:
	price = round(item.get_coin_cost() * (1 - discount))
	price_label.text = str(price)


func can_pick_up_item(player: Player) -> bool:
	if (SavedData.run_stats.coins < price and get_tree().current_scene.name == "Game") or (SavedData.data.dark_souls < price and get_tree().current_scene.name != "Game"):
		return false
	return item.can_pick_up(Globals.player)


func _pick_item_and_free() -> void:
	if get_tree().current_scene.name == "Game":
		SavedData.run_stats.coins -= price
	else:
		SavedData.set_dark_souls(SavedData.data.dark_souls - price)

	var sound: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	sound.stream = load("res://Audio/Sounds/Change-www.fesliyanstudios.com.mp3")
	sound.position = global_position
	sound.bus = "Sounds"
	sound.finished.connect(func():
		sound.queue_free()
	)
	get_tree().current_scene.add_child(sound)
	sound.play()

	if get_tree().current_scene.name == "Game":
		super()
	else: # BaseCamp
		if item is WeaponItem:
			SavedData.discover_weapon(item.weapon.scene_file_path)
		elif item is TemporalPassiveItem:
			SavedData.discover_temporal_item(item.get_script().get_path())
		queue_free()
