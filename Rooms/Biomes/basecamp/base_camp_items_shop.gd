class_name BaseCampItemsShop extends Shop


func _ready() -> void:
	if not SavedData.data.items_shop_unlocked:
		queue_free()

	super()
