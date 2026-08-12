extends Panel

## Attach to inventory.tscn's "inventory" Panel — the actual bag window.
## Builds the item-slot grid from the real Inventory autoload
## (Inventory.items: item_id -> count) and rebuilds it whenever inventory
## changes, so this always reflects what the player is actually carrying.
## Nothing is hand-placed in the editor anymore.

const ItemSlotScene: PackedScene = preload("res://scenes/UI/item_slot.tscn")

@onready var grid: GridContainer = $MarginContainer/GridContainer

var data_bk


func _ready() -> void:
	visible = false
	Inventory.inventory_changed.connect(_on_inventory_changed)
	Inventory.hotbar_changed.connect(_on_hotbar_changed)
	_rebuild_grid()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_I:
		visible = not visible


func _on_inventory_changed(_item_id: String, _new_amount: int) -> void:
	_rebuild_grid()


## Equip/unequip doesn't change item counts (no inventory_changed signal),
## so refresh just the "equipped" badges on existing slots — no need to
## tear down and rebuild the whole grid for this.
func _on_hotbar_changed(_index: int, _item_id: String) -> void:
	for slot in grid.get_children():
		slot.update_ui()


func _rebuild_grid() -> void:
	for child in grid.get_children():
		child.queue_free()

	var ids: Array = Inventory.items.keys()
	ids.sort()  # stable order so slots don't jump around as counts change

	for item_id in ids:
		if Inventory.get_amount(item_id) <= 0:
			continue
		var slot: ItemSlotInventory = ItemSlotScene.instantiate()
		grid.add_child(slot)
		slot.set_item(item_id)


func _process(_delta: float) -> void:
	if Input.get_current_cursor_shape() == CURSOR_FORBIDDEN:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)


## Catches drops anywhere in the bag window, not just precisely on an
## existing item icon — individual ItemSlot children already handle
## drops landing on them; this fills in the empty space around them.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("from_hotbar_index")


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	Inventory.set_hotbar_slot(data["from_hotbar_index"], "")


func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_BEGIN:
		data_bk = get_viewport().gui_get_drag_data()
	if what == Node.NOTIFICATION_DRAG_END:
		data_bk = null
