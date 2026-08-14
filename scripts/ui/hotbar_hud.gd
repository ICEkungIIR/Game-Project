extends Control

## Attach to hotbar_HUD.tscn root (Control).
## Builds 10 HotbarSlot children over the Hotbar.png background and keeps
## them synced with Inventory.hotbar_slots / Inventory.items.
##
## The background art (Hotbar.png) already draws the 10-slot frame, so
## this only needs to overlay icons/counts in the right spot. Values below
## are pre-computed from Hotbar.png's actual bar position (1536x1024
## texture, bar content ~x:116-1418 y:340-575, Sprite2D scale 0.5341797,
## centered) — should line up closely out of the box, but nudge in the
## Inspector while the game is running if the art shifts.

@export var slot_area_position: Vector2 = Vector2(-330, -60)
@export var slot_area_size: Vector2 = Vector2(62, 62)  # size of ONE slot
@export var slot_spacing: float = 4.0

var slots: Array[HotbarSlot] = []


func _ready() -> void:
	for i in Inventory.HOTBAR_SIZE:
		var slot := HotbarSlot.new()
		add_child(slot)
		slot.set_index(i)
		slot.position = slot_area_position + Vector2((slot_area_size.x + slot_spacing) * i, 0)
		slot.size = slot_area_size
		slots.append(slot)

	Inventory.hotbar_changed.connect(_on_hotbar_changed)
	Inventory.hotbar_selected.connect(_on_hotbar_selected)
	Inventory.inventory_changed.connect(_on_inventory_changed)

	_refresh_all()
	_on_hotbar_selected(Inventory.selected_hotbar_index, Inventory.get_selected_item())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var digit_index := _keycode_to_hotbar_index(event.keycode)
		if digit_index != -1:
			Inventory.select_hotbar_slot(digit_index)


## Maps 1-9,0 (top-row number keys) to hotbar index 0-9.
func _keycode_to_hotbar_index(keycode: int) -> int:
	if keycode >= KEY_1 and keycode <= KEY_9:
		return keycode - KEY_1
	if keycode == KEY_0:
		return 9
	return -1


func _on_hotbar_changed(index: int, item_id: String) -> void:
	slots[index].update_item(item_id)


func _on_hotbar_selected(index: int, _item_id: String) -> void:
	for i in slots.size():
		slots[i].set_selected(i == index)


func _on_inventory_changed(item_id: String, new_amount: int) -> void:
	# An item's count changed — refresh (or auto-unequip if it's gone) any
	# hotbar slot pointing at it, e.g. after selling the whole stack.
	for i in Inventory.HOTBAR_SIZE:
		if Inventory.hotbar_slots[i] == item_id:
			if new_amount <= 0:
				Inventory.set_hotbar_slot(i, "")  # emits hotbar_changed -> clears the slot's icon
			else:
				slots[i].update_item(item_id)


func _refresh_all() -> void:
	for i in Inventory.HOTBAR_SIZE:
		slots[i].update_item(Inventory.hotbar_slots[i])
