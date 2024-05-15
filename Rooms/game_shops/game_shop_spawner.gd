@tool
class_name GameShopSpawner extends Marker2D

@export var preview_level: int = 1:
    set(new_preview_level):
        preview_level = new_preview_level
        _change_shop(new_preview_level)

func _init() -> void:
    y_sort_enabled = true

func _ready() -> void:
    if not Engine.is_editor_hint():
        _change_shop(SavedData.data.game_shop_level)
    else:
        _change_shop(preview_level)

func _change_shop(level: int) -> void:
    if get_child(0) != null:
        get_child(0).free()

    var shop_path: String = Data.GAME_SHOPS_PATH.path_join("game_shop_level_%d.tscn" % level)

    if not FileAccess.file_exists(shop_path):
        Log.warn("Shop level " + str(level) + " does not exist!")
        return

    var shop: Node2D = load(shop_path).instantiate()
    add_child(shop)