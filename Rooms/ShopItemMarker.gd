class_name ShopItemMarker extends Marker2D

enum Type {
	TEMPORAL_ITEM,
	WEAPON,
	PLAYER_UPGRADE,
	PERMANENT_ITEM,
	ARMOR,
	CONSUMABLE
}

@export var item_type: Type
@export var quality: Item.Quality
