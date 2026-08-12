extends Node

## Autoload singleton: InventoryManager
## Add this script as an Autoload named "Inventory" in Project Settings.
## Usage from anywhere: Inventory.add_item("carrot", 3)

signal inventory_changed(item_id: String, new_amount: int)

# item_id -> quantity
var items: Dictionary = {}

# Optional: max stack size per item, defaults to 99 if not listed
var max_stack: Dictionary = {
	"carrot": 99,
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
