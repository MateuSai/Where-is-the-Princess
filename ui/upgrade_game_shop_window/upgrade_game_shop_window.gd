class_name UpgradeGameShopWindow extends PopupConfirmation

var cost: int = -1

@onready var label: Label = $VBoxContainer/Label

func _ready() -> void:
    super()

    assert(cost != - 1)

    label.text = tr("UPGRADE_SHOP") % cost