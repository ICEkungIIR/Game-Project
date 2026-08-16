extends Panel
class_name ItemSlotInventory

## One slot in the inventory bag grid. Built + populated at runtime by
## inventory.gd from the real Inventory autoload (Inventory.items) — you
## don't assign an item in the editor anymore.
##
## Drag out of a slot to place that item into a hotbar slot. Bag slots
## are NOT drop targets themselves: the grid rebuilds from Inventory.items
## every time it changes, so there's no persistent "slot position" here
## to drop onto — drag onto the hotbar instead.

@onready var icon: TextureRect = $Item
@onready var count_label: Label = $CountLabel
@onready var equipped_badge: Control = $EquippedBadge

var item_id: String = ""


func _ready() -> void:
	update_ui()


func set_item(id: String) -> void:
	item_id = id
	if is_inside_tree():
		update_ui()


func update_ui() -> void:
	if item_id == "":
		icon.texture = null
		count_label.text = ""
		tooltip_text = ""
		equipped_badge.visible = false
		return

	var crop_data: CropData = CropDB.get_crop(item_id)
	if crop_data:
		icon.texture = crop_data.icon
		tooltip_text = crop_data.crop_id
	else:
		var tool_data: Tools = ToolDB.get_tool(item_id)
		icon.texture = tool_data.icon if tool_data else null
		tooltip_text = tool_data.tools_id if tool_data else item_id

	var amount: int = Inventory.get_amount(item_id)
	count_label.text = str(amount) if amount > 1 else ""

	equipped_badge.visible = Inventory.hotbar_slots.has(item_id)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if item_id == "":
		return null
	if Inventory.hotbar_slots.has(item_id):
		return null  # already equipped somewhere — nothing to do by dragging it again

	var preview := TextureRect.new()
	preview.texture = icon.texture
	preview.custom_minimum_size = Vector2(64, 64)
	preview.position -= Vector2(32, 32)
	set_drag_preview(preview)

	return {"item_id": item_id}


## Bag slots aren't real "positions" (the grid rebuilds from Inventory.items
## on every change), so dropping here doesn't move an item to THIS slot —
## it's just "put it back in the bag", i.e. unequip from wherever it came
## from. Only accepts drags that came from a hotbar slot.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("from_hotbar_index")


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	Inventory.set_hotbar_slot(data["from_hotbar_index"], "")
