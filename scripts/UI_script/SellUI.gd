extends Control

## Autoload singleton: SellUI
## Scene: scenes/UI/Selling_UI.tscn (root node type is Control)
##
## Design: Item_box in item_list_container is kept as a hidden TEMPLATE row.
## Rows are generated dynamically by duplicating Item_box, one per inventory
## entry, so this scales to any number of crop types without touching the
## scene again.
##
## Each row has its own "Sell" button (sells that item's whole stack).
## Sell_container's global "Sell all" button liquidates the entire inventory
## at once. Total shows the value of everything currently in inventory,
## Coin_amount shows the player's current gold.

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var panel: Panel = $CanvasLayer/Panel
@onready var item_list_container: VBoxContainer = $CanvasLayer/Panel/item_list_container
@onready var item_template: HBoxContainer = $CanvasLayer/Panel/item_list_container/Item_box
@onready var close_button: Button = $CanvasLayer/Panel/close_button
@onready var total_label: Label = $CanvasLayer/Panel/Sell_container/HBoxContainer/Total
@onready var coin_amount_label: Label = $CanvasLayer/Panel/Sell_container/HBoxContainer/Coin_amount
@onready var sell_all_button: Button = $CanvasLayer/Panel/Sell_container/sell_button

var is_open: bool = false  # source of truth for whether the shop is open —
# use this instead of `visible`, since CanvasLayer has its own visibility
# quirks separate from the Control tree


func _ready() -> void:
	print("SellUI ready")
	
	is_open = false
	canvas_layer.visible = false
	item_template.visible = false

	close_button.pressed.connect(close)
	sell_all_button.pressed.connect(_sell_all)

	Inventory.inventory_changed.connect(_on_inventory_changed)
	Money.money_changed.connect(_on_money_changed)


func _on_inventory_changed(_id, _amt) -> void:
	if is_open:
		_refresh()


func _on_money_changed(_amt) -> void:
	_update_coin_label()


func open() -> void:
	print("open")
	is_open = true
	canvas_layer.visible = true
	_refresh()
	_update_coin_label()


func close() -> void:
	print("close")
	is_open = false
	canvas_layer.visible = false


func _refresh() -> void:
	# clear previously generated rows, keep the header Label and the template
	for child in item_list_container.get_children():
		if child == item_template or child.name == "item_list":
			continue
		child.queue_free()

	var total_value := 0
	for item_id: String in Inventory.items.keys():
		var qty: int = Inventory.items[item_id]
		if qty <= 0:
			continue
		var data: CropData = CropDB.get_crop(item_id)
		if data == null:
			continue  # no CropData registered for this item_id yet
		total_value += data.sell_price * qty
		_add_row(data, qty)

	total_label.text = "Total: %d gold" % total_value


func _add_row(data: CropData, qty: int) -> void:
	var row: HBoxContainer = item_template.duplicate()
	row.visible = true
	row.get_node("item_img").text = data.crop_id  # TODO: swap for real icon/TextureRect
	row.get_node("item_name").text = "x%d  (%d each)" % [qty, data.sell_price]

	var row_sell_btn: Button = row.get_node("Sell")
	row_sell_btn.pressed.connect(func(): _sell_one_stack(data))

	item_list_container.add_child(row)


func _sell_one_stack(data: CropData) -> void:
	var qty: int = Inventory.get_amount(data.crop_id)
	if qty <= 0:
		return
	if Inventory.remove_item(data.crop_id, qty):
		Money.add(data.sell_price * qty)
	_refresh()


func _sell_all() -> void:
	for item_id: String in Inventory.items.keys().duplicate():
		var qty: int = Inventory.items[item_id]
		var data: CropData = CropDB.get_crop(item_id)
		if data == null or qty <= 0:
			continue
		Inventory.remove_item(item_id, qty)
		Money.add(data.sell_price * qty)
	_refresh()


func _update_coin_label() -> void:
	coin_amount_label.text = "%d" % Money.amount
