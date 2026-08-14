extends CanvasLayer

## Attach to HUD.tscn's root "HUD" (CanvasLayer).
##
## Hides CharacterPanel (health/mana/stamina) whenever another full-screen
## UI is open on top of it — Selling_UI, the inventory bag, etc. — and
## restores it once everything closes. To make a future overlay UI also
## hide the panel, either connect its open/close signals here (like SellUI)
## or make sure it's a CanvasItem whose `visible` toggles (like inventory,
## whose built-in visibility_changed signal is used directly).

@onready var character_panel: Control = $CharacterPanel
@onready var inventory_panel: Control = $InventoryPanel


func _ready() -> void:
	SellUI.opened.connect(_update_character_panel_visibility)
	SellUI.closed.connect(_update_character_panel_visibility)
	inventory_panel.visibility_changed.connect(_update_character_panel_visibility)
	_update_character_panel_visibility()


func _update_character_panel_visibility() -> void:
	character_panel.visible = not SellUI.is_open
