extends Panel
class_name HotbarSlot

## One slot inside hotbar_HUD. Built at runtime by hotbar_hud.gd — you
## don't need to place this in a scene by hand, but you CAN turn it into
## its own .tscn later (swap the icon/count/highlight lookups below for
## @onready if you do, and instantiate that scene from hotbar_hud.gd
## instead of building nodes in code).

var slot_index: int = -1

var icon: TextureRect
var count_label: Label
var highlight: ColorRect


func _ready() -> void:
	custom_minimum_size = Vector2(72, 72)

	highlight = ColorRect.new()
	highlight.color = Color(1, 1, 1, 0.25)
	highlight.anchor_right = 1.0
	highlight.anchor_bottom = 1.0
	highlight.visible = false
	add_child(highlight)

	icon = TextureRect.new()
	icon.anchor_right = 1.0
	icon.anchor_bottom = 1.0
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(icon)

	count_label = Label.new()
	count_label.anchor_left = 1.0
	count_label.anchor_top = 1.0
	count_label.anchor_right = 1.0
	count_label.anchor_bottom = 1.0
	count_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	count_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(count_label)


func set_index(i: int) -> void:
	slot_index = i


func set_selected(is_selected: bool) -> void:
	highlight.visible = is_selected


## item_id == "" means empty slot.
func update_item(item_id: String) -> void:
	if item_id == "":
		icon.texture = null
		count_label.text = ""
		return

	var crop_data: CropData = CropDB.get_crop(item_id)
	if crop_data and crop_data.icon:
		icon.texture = crop_data.icon
	elif crop_data and not crop_data.stage_textures.is_empty():
		icon.texture = crop_data.stage_textures[-1]
	else:
		var tool_data: Tools = ToolDB.get_tool(item_id)
		icon.texture = tool_data.icon if tool_data else null

	var amount: int = Inventory.get_amount(item_id)
	count_label.text = str(amount) if amount > 1 else ""


## Accepts drags from inventory bag slots (item_slot_inventory.gd hands
## back {"item_id": ...}) and places that item in this hotbar slot.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("item_id")


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	Inventory.set_hotbar_slot(slot_index, data["item_id"])
	# If this came from another hotbar slot, move it rather than copy —
	# clear the slot it came from (unless dropped on itself).
	if data.has("from_hotbar_index") and data["from_hotbar_index"] != slot_index:
		Inventory.set_hotbar_slot(data["from_hotbar_index"], "")


## Lets you drag an item OUT of this hotbar slot — either to unequip it
## by dropping on the bag, or to move it to a different hotbar slot.
func _get_drag_data(_at_position: Vector2) -> Variant:
	var item_id: String = Inventory.hotbar_slots[slot_index]
	if item_id == "":
		return null

	var preview := TextureRect.new()
	preview.texture = icon.texture
	preview.custom_minimum_size = Vector2(64, 64)
	preview.position -= Vector2(32, 32)
	set_drag_preview(preview)

	return {"item_id": item_id, "from_hotbar_index": slot_index}
