extends Node

## Autoload singleton: InventoryManager
## Add this script as an Autoload named "Inventory" in Project Settings.
## Usage from anywhere: Inventory.add_item("carrot", 3)

signal inventory_changed(item_id: String, new_amount: int)
signal hotbar_changed(index: int, item_id: String)
signal hotbar_selected(index: int, item_id: String)
signal item_obtained(item_id: String, amount: int)

# item_id -> quantity
var items: Dictionary = {}

# Hotbar is just 10 "pointers" into items{} — the item_id sitting in each
# slot (or "" if empty). Quantity shown per slot is always read live from
# items[item_id], so it never needs to be synced separately.
const HOTBAR_SIZE: int = 10
var hotbar_slots: Array[String] = ["", "", "", "", "", "", "", "", "", ""]
var selected_hotbar_index: int = 0
var stacks = 64
# Optional: max stack size per item, defaults to 99 if not listed
var max_stack: Dictionary = {
	"carrot": stacks,
	"tomato": 99,
	"potato": 99,
	"pumpkin": 99,
	"milk": 99,
	"egg": 99,
	"slime_jelly": 99,
	"magic_honey": 99,
	"bread": 99,
	"soup": 99,
	"stew": 99,
	"cake": 99,
}


func add_item(item_id: String, amount: int = 1) -> void:
	var current: int = items.get(item_id, 0)
	var cap: int = max_stack.get(item_id, 99)
	items[item_id] = min(current + amount, cap)
	inventory_changed.emit(item_id, items[item_id])
	item_obtained.emit(item_id, amount)


func remove_item(item_id: String, amount: int = 1) -> bool:
	var current: int = items.get(item_id, 0)
	if current < amount:
		return false
	items[item_id] = current - amount
	if items[item_id] <= 0:
		items.erase(item_id)
		inventory_changed.emit(item_id, 0)
	else:
		inventory_changed.emit(item_id, items[item_id])
	return true


func has_item(item_id: String, amount: int = 1) -> bool:
	return items.get(item_id, 0) >= amount


func get_amount(item_id: String) -> int:
	return items.get(item_id, 0)


## --- Hotbar ---------------------------------------------------------

## Place item_id in a hotbar slot. Pass "" to clear the slot.
func set_hotbar_slot(index: int, item_id: String) -> void:
	if index < 0 or index >= HOTBAR_SIZE:
		return
	hotbar_slots[index] = item_id
	hotbar_changed.emit(index, item_id)


func get_hotbar_item(index: int) -> String:
	if index < 0 or index >= HOTBAR_SIZE:
		return ""
	return hotbar_slots[index]


func select_hotbar_slot(index: int) -> void:
	if index < 0 or index >= HOTBAR_SIZE:
		return
	selected_hotbar_index = index
	hotbar_selected.emit(index, hotbar_slots[index])


## The item currently "in hand" — what F/interact-use should act on.
func get_selected_item() -> String:
	return hotbar_slots[selected_hotbar_index]
