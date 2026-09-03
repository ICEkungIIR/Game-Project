extends VBoxContainer

## Attach to HUD.tscn's "ItemNotifyStack" VBoxContainer.
##
## Listens for Inventory.item_obtained and spawns a self-contained,
## self-destructing item_notify_entry.tscn toast for each pickup. Multiple
## pickups in quick succession each get their own stacked line — the
## container is bottom-left anchored with grow_vertical = 0, so it grows
## upward as entries stack, and shrinks back down as each one frees itself.

const ItemNotifyEntryScene: PackedScene = preload("res://scenes/hud/item_notify_entry.tscn")


func _ready() -> void:
	Inventory.item_obtained.connect(_on_item_obtained)


func _on_item_obtained(item_id: String, amount: int) -> void:
	var entry: Control = ItemNotifyEntryScene.instantiate()
	entry.set_notification(item_id, amount)
	add_child(entry)
