class_name ShopItemMarker extends Marker2D

enum Type {
	TEMPORAL_ITEM,
	WEAPON,
	PLAYER_UPGRADE,
}

@export var item_type: Type
