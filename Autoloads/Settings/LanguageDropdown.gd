extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_item("en")
	for locale in TranslationServer.get_loaded_locales():
		add_item(locale)

	#select(TranslationServer.get_locale())

	item_selected.connect(func(index: int):
		TranslationServer.set_locale(get_item_text(index))
	)
